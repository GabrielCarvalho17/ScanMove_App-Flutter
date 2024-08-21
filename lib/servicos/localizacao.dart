import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/localizacao.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

enum StatusLocalizacao {
  sucesso,
  timeout,
  semConexao,
  erroServidor,
  localizacaoNaoEncontrada,
}

class ServLocalizacao {
  final SQLite _dbHelper = SQLite();

  Future<Map<String, dynamic>> fetchLocalizacao(String localizacao) async {
    try {
      // Obter a localização da API
      final response = await _fetchLocalizacao(localizacao);

      // Verificar o status da resposta
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Verifica se o retorno é um objeto (Map) e se contém as chaves necessárias
        if (data is Map<String, dynamic> && data.containsKey('localizacao')) {
          return {
            'status': StatusLocalizacao.sucesso,
            'localizacao': LocalizacaoModel.fromJson(data),
          };
        } else {
          return {
            'status': StatusLocalizacao.localizacaoNaoEncontrada,
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'status': StatusLocalizacao.localizacaoNaoEncontrada,
        };
      } else {
        return {
          'status': StatusLocalizacao.erroServidor,
        };
      }
    } on TimeoutException {
      return {
        'status': StatusLocalizacao.timeout,
      };
    } on SocketException {
      return {
        'status': StatusLocalizacao.semConexao,
      };
    } catch (e) {
      return {
        'status': StatusLocalizacao.erroServidor,
        'mensagem': e.toString(),
      };
    }
  }

  Future<http.Response> _fetchLocalizacao(String localizacao) async {
    // Obter o usuário ativo do banco de dados
    final List<Map<String, dynamic>> users = await _dbHelper.listar(
      'USUARIO',
      where: 'access_token IS NOT NULL AND access_token != ""',
    );

    if (users.isEmpty) {
      throw Exception('Usuário não encontrado no banco de dados.');
    }

    // Obter o token do primeiro usuário encontrado
    String token = users.first['access_token'];
    final url = Uri.parse('${Config.baseUrl}/materiais/localizacao/$localizacao/');

    // Fazer a requisição à API
    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 15)); // Define o timeout para a requisição
  }
}
