import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/localizacao.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:AppEstoqueMP/servicos/autenticacao.dart';

class LocalizacaoNotFoundException implements Exception {
  final String message;
  LocalizacaoNotFoundException(this.message);
}

class ServLocalizacao {
  final SQLite _dbHelper = SQLite();
  final ServAutenticacao _servAutenticacao = ServAutenticacao();

  Future<Localizacao> fetchLocalizacao(String localizacao) async {
    final response = await _servAutenticacao.makeAuthenticatedRequest(
          () => _fetchLocalizacao(localizacao),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return Localizacao.fromJson(data['results'][0]);
      } else {
        throw LocalizacaoNotFoundException('Localização não encontrada.');
      }
    } else if (response.statusCode == 404) {
      throw LocalizacaoNotFoundException('Localização não encontrada.');
    } else {
      throw Exception('Erro ao buscar dados da localização. Código de status: ${response.statusCode}');
    }
  }

  Future<http.Response> _fetchLocalizacao(String localizacao) async {
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuario();
    if (users.isEmpty) {
      throw Exception('Usuário não encontrado no banco de dados.');
    }

    String token = users.first['access_token'];
    final url = Uri.parse('${Config.baseUrl}/materiais/localizacoes/$localizacao/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 15));

    return response;
  }
}
