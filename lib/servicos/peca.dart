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
      final response = await _fetchPeca(peca);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'status': StatusPeca.sucesso,
            'peca': PecaModel.fromJson(data[0]),  // Pega o primeiro item da lista
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
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuarios();
    if (users.isEmpty) {
      throw Exception('Usuário não encontrado no banco de dados.');
    }

    String token = users.first['access_token'];
    final url = Uri.parse('${Config.baseUrl}/materiais/peca/$peca/');

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 15)); // Define o timeout para o request
  }
}
