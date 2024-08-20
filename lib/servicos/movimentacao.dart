import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/movimentacao.dart';
import 'package:AppEstoqueMP/modelos/peca.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

import 'config.dart';

class ServMovimentacao {
  final SQLite _dbHelper = SQLite();

  // Método para obter o token de um usuário com access_token válido
  Future<String?> _obterToken() async {
    final List<Map<String, dynamic>> usuarios = await _dbHelper.listar(
      'USUARIO',
      where: 'access_token IS NOT NULL AND access_token != ""',
    );

    if (usuarios.isNotEmpty) {
      return usuarios.first['access_token'];
    }
    return null;
  }

  Future<List<MovimentacaoModel>> obterMovimentacoesDoServidor() async {
    final movimentacoesExistentes = await getMovimentacoesExistentes();

    if (movimentacoesExistentes.isNotEmpty) {
      // Retorna as movimentações existentes no banco de dados local, caso não esteja vazio
      return movimentacoesExistentes;
    }

    // Se o banco de dados local estiver vazio, faz a carga do servidor
    final url = '${Config.baseUrl}/materiais/movimentacoes/';
    final token = await _obterToken();

    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<MovimentacaoModel> movimentacoes = [];

        for (var jsonMov in data) {
          final pecas = (jsonMov['pecas'] as List<dynamic>)
              .map((itemJson) => PecaModel.fromJson(itemJson))
              .toList();

          int movSqlite = await _dbHelper.inserir('ESTOQUE_MAT_MOV', {
            'data_inicio': jsonMov['data_inicio'],
            'data_modificacao': jsonMov['data_modificacao'],
            'status': jsonMov['status'],
            'usuario': jsonMov['usuario'],
            'origem': jsonMov['origem'],
            'destino': jsonMov['destino'],
            'total_pecas': jsonMov['total_pecas'],
            'mov_servidor': jsonMov['movimentacao'],
            'filial_origem': jsonMov['filial_origem'],
            'filial_destino': jsonMov['filial_destino'],
          });

          // Atualize as pecas com o movSqlite retornado e insira-os na base de dados local
          for (var peca in pecas) {
            await _dbHelper.inserir('ESTOQUE_MAT_MOV_PECA', {
              'peca': peca.peca,
              'material': peca.material,
              'cor_material': peca.corMaterial,
              'partida': peca.partida,
              'unidade': peca.unidade,
              'quantidade': peca.quantidade,
              'mov_sqlite': movSqlite,
              'desc_material': peca.descMaterial,
              'desc_cor_material': peca.descCorMaterial,
              'localizacao': jsonMov['origem'],
              'filial': peca.filial,
            });
          }

          movimentacoes.add(MovimentacaoModel(
            movServidor: jsonMov['movimentacao'],
            dataInicio: jsonMov['data_inicio'],
            dataModificacao: jsonMov['data_modificacao'],
            status: jsonMov['status'],
            usuario: jsonMov['usuario'],
            origem: jsonMov['origem'],
            destino: jsonMov['destino'],
            totalPecas: jsonMov['total_pecas'],
            filialOrigem: jsonMov['filial_origem'],
            filialDestino: jsonMov['filial_destino'],
            pecas: pecas,
          ));
        }

        return movimentacoes;
      } else {
        throw Exception('Erro ao obter movimentações: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<bool> deletarMovimentoLocal(int movServidor) async {
    final int result = await _dbHelper.deletar('ESTOQUE_MAT_MOV', movServidor);
    return result >
        0; // Retorna true se alguma linha foi deletada, caso contrário, false
  }

  Future<List<MovimentacaoModel>> getMovimentacoesExistentes() async {
    final movimentacoesDb = await _dbHelper.listar('ESTOQUE_MAT_MOV');

    return movimentacoesDb.map((mov) {
      return MovimentacaoModel(
        movServidor: mov['mov_servidor'],
        dataInicio: mov['data_inicio'],
        dataModificacao: mov['data_modificacao'],
        status: mov['status'],
        usuario: mov['usuario'],
        origem: mov['origem'],
        destino: mov['destino'],
        totalPecas: mov['total_pecas'],
        filialOrigem: mov['filial_origem'],
        filialDestino: mov['filial_destino'],
        pecas: [], // Você pode preencher esta lista conforme necessário
      );
    }).toList();
  }

  Future<List<MovimentacaoModel>> getMovimentacoesDoSQLite() async {
    final movimentacoesDb = await _dbHelper.listar('ESTOQUE_MAT_MOV');

    List<MovimentacaoModel> movimentacoes = [];

    for (var mov in movimentacoesDb) {
      // Carrega as peças associadas à movimentação atual
      final pecasDb = await _dbHelper.listar(
        'ESTOQUE_MAT_MOV_PECA',
        where: 'mov_sqlite = ?',
        whereArgs: [mov['mov_sqlite']],
      );

      List<PecaModel> pecas = pecasDb.map((peca) {
        return PecaModel(
          peca: peca['peca'],
          partida: peca['partida'],
          material: peca['material'],
          descMaterial: peca['desc_material'],
          corMaterial: peca['cor_material'],
          descCorMaterial: peca['desc_cor_material'],
          localizacao: peca['localizacao'],
          unidade: peca['unidade'],
          quantidade: peca['quantidade'],
          filial: peca['filial'],
        );
      }).toList();

      movimentacoes.add(MovimentacaoModel(
        movServidor: mov['mov_servidor'],
        dataInicio: mov['data_inicio'],
        dataModificacao: mov['data_modificacao'],
        status: mov['status'],
        usuario: mov['usuario'],
        origem: mov['origem'],
        destino: mov['destino'],
        totalPecas: mov['total_pecas'],
        filialOrigem: mov['filial_origem'],
        filialDestino: mov['filial_destino'],
        pecas: pecas,
      ));
    }

    return movimentacoes;
  }

}
