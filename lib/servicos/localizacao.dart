import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/localizacao.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class ServLocalizacao {
  final SQLite _dbHelper = SQLite();

  Future<Map<String, dynamic>> fetchLocalizacao(String localizacao) async {
    try {
      // Obter o token do banco de dados
      final token = await _obterToken();

      // Montar a URL para a requisição
      final url = Uri.parse('${Config.baseUrl}/materiais/localizacao/$localizacao/');

      // Fazer a requisição com timeout
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
            'message': 'Localização encontrada com sucesso',
            'localizacao': LocalizacaoModel.fromJson(data),
          };
        } else {
          return {
            'status': 404,
            'message': 'Localização não encontrada',
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'status': 404,
          'message': 'Localização não encontrada',
        };
      } else if (response.statusCode == 408) {
        return {
          'status': 408,
          'message': 'O servidor demorou demais para responder',
        };
      } else {
        return {
          'status': response.statusCode,
          'message': 'Erro ao buscar localização',
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
