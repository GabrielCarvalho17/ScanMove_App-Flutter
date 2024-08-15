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
      final response = await _fetchLocalizacao(localizacao);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return {
            'status': StatusLocalizacao.sucesso,
            'localizacao': LocalizacaoModel.fromJson(data['results'][0]),
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
      };
    }
  }

  Future<http.Response> _fetchLocalizacao(String localizacao) async {
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuarios();
    if (users.isEmpty) {
      throw Exception('Usuário não encontrado no banco de dados.');
    }

    String token = users.first['access_token'];
    final url = Uri.parse('${Config.baseUrl}/materiais/localizacoes/$localizacao/');

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 15)); // Define o timeout para o request
  }
}
