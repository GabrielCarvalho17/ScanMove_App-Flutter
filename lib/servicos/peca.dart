import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/peca.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

enum StatusPeca {
  sucesso,
  timeout,
  semConexao,
  erroServidor,
  pecaNaoEncontrada,
}

class ServPeca {
  final SQLite _dbHelper = SQLite();

  Future<Map<String, dynamic>> fetchPeca(String peca) async {
    try {
      // Obter a peça da API
      final response = await _fetchPeca(peca);

      // Verificar o status da resposta
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Retornar a peça encontrada
          return {
            'status': StatusPeca.sucesso,
            'peca': PecaModel.fromJson(data),  // Converte o JSON para PecaModel
          };
        } else {
          return {
            'status': StatusPeca.pecaNaoEncontrada,
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'status': StatusPeca.pecaNaoEncontrada,
        };
      } else {
        return {
          'status': StatusPeca.erroServidor,
        };
      }
    } on TimeoutException {
      return {
        'status': StatusPeca.timeout,
      };
    } on SocketException {
      return {
        'status': StatusPeca.semConexao,
      };
    } catch (e) {
      return {
        'status': StatusPeca.erroServidor,
      };
    }
  }

  Future<http.Response> _fetchPeca(String peca) async {
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
    final url = Uri.parse('${Config.baseUrl}/materiais/peca/$peca/');

    // Fazer a requisição à API
    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 15)); // Define o timeout para a requisição
  }
}
