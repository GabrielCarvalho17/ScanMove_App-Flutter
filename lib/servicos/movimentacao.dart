import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/movimentacao.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class ServMovimentacao {
  final SQLite _dbHelper = SQLite();

  Future<void> enviarMovimentacao(Movimentacao movimentacao) async {
    final url = '${Config.baseUrl}/materiais/movimentacoes/';

    // Converte a movimentacao para JSON sem incluir 'movSqlite'
    final Map<String, dynamic> body = movimentacao.toJson();

    try {
      // Envia a movimentação ao servidor
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final int movServidorId = data['id_sqlite'];
        print('Movimentação enviada com sucesso! ID do servidor: $movServidorId');

        // Atualiza o SQLite com o ID do servidor para cada item da movimentação
        for (final item in movimentacao.itens) {
          await _dbHelper.atualizarItem(item.movSqlite, {
            'mov_servidor': movServidorId,
          });
        }
      } else {
        throw Exception('Erro ao enviar movimentação: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao enviar movimentação: $e');
      throw e;
    }
  }
}
