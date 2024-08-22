import 'dart:convert';
import 'dart:async';
import 'package:AppEstoqueMP/modelos/autenticacao.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:http/http.dart' as http;

class ServAutenticacao {
  final SQLite _dbSqlite = SQLite();
  static const int _maxRetryAttempts = 3; // Número máximo de tentativas

  Future<Autenticacao> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Config.baseUrl}/token/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'username': username,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));

        final List<Map<String, dynamic>> users = await _dbSqlite.listar(
          'USUARIO',
          where: 'username = ?',
          whereArgs: [username],
        );

        if (users.isNotEmpty) {
          await _dbSqlite.atualizar(
            tabela: 'USUARIO',
            valores: {
              'username': username,
              'access_token': data['access'],
              'refresh_token': data['refresh'],
            },
            whereClausula: {
              'id': users.first['id'],
            },
          );
        } else {
          await _dbSqlite.inserir('USUARIO', {
            'username': username,
            'access_token': data['access'],
            'refresh_token': data['refresh'],
          });
        }

        return Autenticacao.fromJson(data);
      } else {
        final Map<String, dynamic> errorData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage =
            errorData['detail'] ?? 'Usuário e/ou senha incorretos';
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
          'O servidor não está respondendo. Tente novamente mais tarde.');
    } on http.ClientException {
      throw Exception(
          'Não foi possível conectar ao servidor. Verifique sua conexão com a internet ou tente novamente mais tarde.');
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      throw Exception(errorMessage);
    }
  }

  Future<void> refreshToken() async {
    final List<Map<String, dynamic>> users = await _dbSqlite.listar(
      'USUARIO',
      where: 'access_token IS NOT NULL AND access_token != ""',
    );
    if (users.isNotEmpty) {
      final String refreshToken = users.first['refresh_token'];
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/token/refresh/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'refresh': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        await _dbSqlite.atualizar(
          tabela: 'USUARIO',
          valores: {
            'access_token': data['access'],
          },
          whereClausula: {
            'id': users.first['id'],
          },
        );
      } else {
        final Map<String, dynamic> errorData =
            jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? 'Falha ao atualizar token');
      }
    }
  }

  Future<http.Response> makeAuthenticatedRequest(
      Future<http.Response> Function() request) async {
    int attempts = 0;
    http.Response response;

    while (attempts < _maxRetryAttempts) {
      response = await request();

      if (response.statusCode != 401) {
        return response;
      }

      attempts++;

      try {
        await refreshToken();
      } catch (e) {
        if (attempts >= _maxRetryAttempts) {
          throw Exception('Falha ao renovar token após $attempts tentativas');
        }
      }
    }

    return await request(); // Tenta novamente a requisição original após renovar o token
  }

  Future<http.Response> get(String url) async {
    final List<Map<String, dynamic>> users = await _dbSqlite.listar(
      'USUARIO',
      where: 'access_token IS NOT NULL AND access_token != ""',
    );
    final String token = users.isNotEmpty ? users.first['access_token'] : '';

    return makeAuthenticatedRequest(() {
      return http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
    });
  }

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final List<Map<String, dynamic>> users = await _dbSqlite.listar(
      'USUARIO',
      where: 'access_token IS NOT NULL AND access_token != ""',
    );
    final String token = users.isNotEmpty ? users.first['access_token'] : '';

    return makeAuthenticatedRequest(() {
      return http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
    });
  }

  Future<void> logout() async {
    final List<Map<String, dynamic>> users = await _dbSqlite.listar(
      'USUARIO',
      where: 'access_token IS NOT NULL AND access_token != ""',
    );
    if (users.isNotEmpty) {
      await _dbSqlite.atualizar(
        tabela: 'USUARIO',
        valores: {
          'access_token': '',
          'refresh_token': '',
        },
        whereClausula: {
          'id': users.first['id'],
        },
      );
    }
  }
}
