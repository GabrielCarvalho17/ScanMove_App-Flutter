import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/peca.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:AppEstoqueMP/servicos/autenticacao.dart';

class PecaNotFoundException implements Exception {
  final String message;
  PecaNotFoundException(this.message);
}

class ServPeca {
  final SQLite _dbHelper = SQLite();
  final ServAutenticacao _servAutenticacao = ServAutenticacao();

  Future<PecaModel> fetchPeca(String peca) async {
    final response = await _servAutenticacao.makeAuthenticatedRequest(
          () => _fetchPeca(peca),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return PecaModel.fromJson(data['results'][0]);
      } else {
        throw PecaNotFoundException('Peça não encontrada.');
      }
    } else if (response.statusCode == 404) {
      throw PecaNotFoundException('Peça não encontrada.');
    } else {
      throw Exception('Erro ao buscar dados da peça. Código de status: ${response.statusCode}');
    }
  }

  Future<http.Response> _fetchPeca(String peca) async {
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuarios();
    if (users.isEmpty) {
      throw Exception('Usuário não encontrado no banco de dados.');
    }

    String token = users.first['access_token'];
    final url = Uri.parse('${Config.baseUrl}/materiais/peca/$peca/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 15));

    return response;
  }
}
