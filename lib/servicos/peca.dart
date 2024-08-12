import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/peca.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:AppEstoqueMP/servicos/autenticacao.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';

class PecaNotFoundException implements Exception {
  final String message;
  PecaNotFoundException(this.message);
}

class ServPeca {
  final SQLite _dbHelper = SQLite();
  final ServAutenticacao _servAutenticacao = ServAutenticacao();

  Future<PecaModel> fetchPeca(BuildContext context, String peca) async {
    const tempoMinimoParaLoading = Duration(seconds: 1);
    bool loadingExibido = false;

    final Future<void> loadingFuture = Future.delayed(tempoMinimoParaLoading, () {
      loadingExibido = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Aguarde',
            mensagem: 'Processando, por favor aguarde...',
            isLoading: true,
          );
        },
      );
    });

    try {
      final response = await _fetchPeca(peca);

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
    } on TimeoutException {
      throw Exception('O servidor não está respondendo. Tente novamente mais tarde.');
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão com a internet ou tente novamente mais tarde.');
    } finally {
      await loadingFuture;

      if (loadingExibido && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
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
    ).timeout(Duration(seconds: 15));
  }
}
