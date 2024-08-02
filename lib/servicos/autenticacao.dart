import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/modelos/autenticacao.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ServAutenticacao {
  final SQLite _dbHelper = SQLite();
  static const int _maxRetryAttempts = 3; // Número máximo de tentativas

  Future<Autenticacao> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/token/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      ).timeout(Duration(seconds: 15)); // Definindo timeout

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Armazenar os dados no SQLite
        await _dbHelper.inserirUsuario({
          'username': username,
          'password': password,
          'access_token': data['access'],
          'refresh_token': data['refresh'],
        });

        return Autenticacao.fromJson(data);
      } else {
        throw Exception('Falha ao fazer login');
      }
    } catch (e) {
      throw Exception('Falha ao fazer login');
    }
  }

  Future<void> refreshToken() async {
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuario();
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
        final Map<String, dynamic> data = jsonDecode(response.body);
        await _dbHelper.atualizarUsuario(users.first['id'], {
          'access_token': data['access'],
        });
      } else {
        throw Exception('Falha ao atualizar token');
      }
    }
  }

  Future<http.Response> makeAuthenticatedRequest(Future<http.Response> Function() request) async {
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

    // Após a renovação do token, tenta novamente a requisição original
    return await request();
  }

  Future<http.Response> get(String url) async {
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuario();
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
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuario();
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
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuario();
    if (users.isNotEmpty) {
      await _dbHelper.deletarUsuario(users.first['id']);
    }
  }
}
