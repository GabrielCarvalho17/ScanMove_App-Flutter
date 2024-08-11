import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/localizacao.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:AppEstoqueMP/servicos/autenticacao.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';

class LocalizacaoNotFoundException implements Exception {
  final String message;
  LocalizacaoNotFoundException(this.message);
}

class ServLocalizacao {
  final SQLite _dbHelper = SQLite();
  final ServAutenticacao _servAutenticacao = ServAutenticacao();

  Future<Localizacao> fetchLocalizacao(BuildContext context, String localizacao) async {
    // Tempo mínimo para exibir o loading
    const tempoMinimoParaLoading = Duration(seconds: 1);
    bool loadingExibido = false;

    // Future para exibir o loading após o tempo mínimo
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
      final response = await _fetchLocalizacao(localizacao);

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
    } on TimeoutException {
      throw Exception('O servidor não está respondendo. Tente novamente mais tarde.');
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão com a internet ou tente novamente mais tarde.');
    } catch (e) {
      throw Exception(_formatErrorMessage(e.toString()));
    } finally {
      // Espera o loadingFuture para garantir que o dialog não foi exibido após o tempo mínimo
      await loadingFuture;

      // Fechar o diálogo de loading apenas se ele foi exibido
      if (loadingExibido && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
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
    ).timeout(Duration(seconds: 15));
  }

  String _formatErrorMessage(String errorMessage) {
    return errorMessage.replaceAll('Exception: ', '').replaceAll('Exception:', '');
  }
}
