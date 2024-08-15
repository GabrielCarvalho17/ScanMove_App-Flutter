import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/movimentacao.dart';
import 'package:AppEstoqueMP/modelos/peca.dart';
import 'package:AppEstoqueMP/servicos/config.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class ServMovimentacao {
  final SQLite _dbHelper = SQLite();

  Future<String?> _obterToken() async {
    final usuarios = await _dbHelper.obterUsuarios();
    if (usuarios.isNotEmpty) {
      return usuarios.first['access_token'];
    }
    return null;
  }

  Future<List<MovimentacaoModel>> obterMovimentacoesDoServidor() async {
    final movimentacoesExistentes = await _dbHelper.getMovimentacoesExistentes();

    if (movimentacoesExistentes.isNotEmpty) {
      // Retorna as movimentações existentes no banco de dados local, caso não esteja vazio
      return movimentacoesExistentes.map((mov) {
        return MovimentacaoModel(
          movServidor: mov['mov_servidor'],
          dataInicio: mov['data_inicio'],
          dataModificacao: mov['data_modificacao'],
          status: mov['status'],
          usuario: mov['usuario'],
          origem: mov['origem'],
          destino: mov['destino'],
          totalPecas: mov['total_pecas'],
          pecas: [], // Lista de pecas pode ser preenchida conforme necessário
        );
      }).toList();
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

          int movSqlite = await _dbHelper.adicionarMovimentacao({
            'data_inicio': jsonMov['data_inicio'],
            'data_modificacao': jsonMov['data_modificacao'],
            'status': jsonMov['status'],
            'usuario': jsonMov['usuario'],
            'origem': jsonMov['origem'],
            'destino': jsonMov['destino'],
            'total_pecas': jsonMov['total_pecas'],
            'mov_servidor': jsonMov['movimentacao'], // Adiciona o mov_servidor
            'filial_origem': jsonMov['filial_origem'],
            'filial_destino': jsonMov['filial_destino'],
          });

          // Atualize os pecas com o movSqlite retornado e insira-os na base de dados local
          for (var peca in pecas) {
            await _dbHelper.adicionarPeca({
              'peca': peca.peca,
              'material': peca.material,
              'cor_material': peca.corMaterial,
              'partida': peca.partida,
              'unidade': peca.unidade,
              'quantidade': peca.quantidade,
              'mov_sqlite': movSqlite, // Associa o movSqlite ao item
              'desc_material': peca.descMaterial,
              'desc_cor_material': peca.descCorMaterial,
              'localizacao': jsonMov['origem'],
              'filial': jsonMov['filial_origem'],
            });
          }

          movimentacoes.add(MovimentacaoModel(
            movServidor: jsonMov['movimentacao'], // Adiciona movServidor ao modelo
            dataInicio: jsonMov['data_inicio'],
            dataModificacao: jsonMov['data_modificacao'],
            status: jsonMov['status'],
            usuario: jsonMov['usuario'],
            origem: jsonMov['origem'],
            destino: jsonMov['destino'],
            totalPecas: jsonMov['total_pecas'],
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
    return await _dbHelper.deletarMovimentacao(movServidor);
  }

  Future<List<MovimentacaoModel>> getMovimentacoesExistentes() async {
    final movimentacoesDb = await _dbHelper.getMovimentacoesExistentes();

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
        pecas: [], // Você pode preencher esta lista conforme necessário
      );
    }).toList();
  }
}
