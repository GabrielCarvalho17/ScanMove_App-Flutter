import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/peca.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class ServPeca {
  final SQLite _dbHelper = SQLite();

  Future<Map<String, dynamic>> fetchPeca(String peca) async {
    try {
      // Obter a peça da API com timeout de 10 segundos
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/materiais/peca/$peca/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _obterToken()}',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        return http.Response(
          'O servidor demorou demais para responder. Tente novamente mais tarde.',
          408,
        );
      });

      // Tratar a resposta da requisição
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'status': 200,
            'message': 'Peça encontrada com sucesso',
            'peca': PecaModel.fromJson(data),
          };
        } else {
          return {
            'status': 404,
            'message': 'Peça não encontrada',
          };
        }
      } else if (response.statusCode == 204) {
        return {
          'status': 204,
          'message': 'Nenhum conteúdo encontrado',
        };
      } else if (response.statusCode == 408) {
        return {
          'status': 408,
          'message': 'Erro ao buscar peça: O servidor demorou demais para responder',
          'error': response.body,
        };
      } else {
        return {
          'status': response.statusCode,
          'message': 'Erro ao buscar peça',
          'error': response.body,
        };
      }
    } on SocketException {
      return {
        'status': 503,
        'message': 'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
      };
    } catch (e) {
      throw Exception('Ocorreu um erro: $e');
    }
  }

  Future<String> _obterToken() async {
    // Obter o usuário ativo do banco de dados
    final List<Map<String, dynamic>> users = await _dbHelper.listar(
      'USUARIO',
      where: 'access_token IS NOT NULL AND access_token != ""',
    );

    if (users.isEmpty) {
      throw Exception('Usuário não encontrado no banco de dados.');
    }

    // Retornar o token do primeiro usuário encontrado
    return users.first['access_token'];
  }
}
