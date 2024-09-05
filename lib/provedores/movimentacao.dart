import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:AppEstoqueMP/servicos/movimentacao.dart';
import 'package:AppEstoqueMP/modelos/movimentacao.dart';
import 'package:AppEstoqueMP/modelos/peca.dart';

class ProvMovimentacao with ChangeNotifier {
  final SQLite _sqlite = SQLite();
  final ServMovimentacao _servMovimentacao = ServMovimentacao();

  MovimentacaoModel? _movimentacaoAtual;
  List<MovimentacaoModel> _movsDoDia = [];
  bool _isLoading = false;
  String? _ultimaCarga;

  List<MovimentacaoModel> get movsDoDia => _movsDoDia;
  bool get isLoading => _isLoading;
  MovimentacaoModel? get movimentacaoAtual => _movimentacaoAtual;

  // Carregar as movimentações do dia
  Future<void> carregarMovsDoDia() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!await _isUsuarioLogado()) {
        throw Exception('Usuário não está logado');
      }

      // Limpar todas as movimentações atuais no banco de dados
      final db = await _sqlite.bancoDados;
      await db.delete('ESTOQUE_MAT_MOV');

      // Recarregar as movimentações do servidor
      final movimentacoes =
          await _servMovimentacao.obterMovimentacoesDoServidor();

      if (movimentacoes.isNotEmpty) {
        _movsDoDia = movimentacoes;

        // Atualizar a data da última carga
        _ultimaCarga = DateFormat('dd-MM-yyyy').format(DateTime.now());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ultimaCarga', _ultimaCarga!);
      }
    } catch (e, stackTrace) {
      print('Erro ao carregar movimentações: $e');
      print('Detalhes do erro: $stackTrace');
      throw e; // Repassa o erro para ser capturado onde o provedor for usado
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verificar e recarregar movimentações apenas se necessário
  Future<void> verificarERecarregarMovs() async {
    final prefs = await SharedPreferences.getInstance();
    _ultimaCarga = prefs.getString('ultimaCarga');

    String dataAtual = DateFormat('dd-MM-yyyy').format(DateTime.now());

    if (!await _isUsuarioLogado()) {
      return;
    } else {
      if (_ultimaCarga != null && _ultimaCarga == dataAtual) {
        print('Movimentações já carregadas hoje. Não será feita nova carga.');

        // Carregar as movimentações do SQLite
        _movsDoDia = await _servMovimentacao.getMovimentacoesDoSQLite();

        _isLoading = false;
        notifyListeners();
        return;
      } else {
        print('Carregando movimentações do dia...');
        await carregarMovsDoDia();
      }
    }
  }

  // Verificar se o usuário está logado
  Future<bool> _isUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioAtual = prefs.getString('usuario_logado');
    return usuarioAtual != null;
  }

  // Cria uma nova movimentação
  Future<void> novaMovimentacao() async {
    final prefs = await SharedPreferences.getInstance();
    final usuario_logado = prefs.getString('usuario_logado');
    _movimentacaoAtual = MovimentacaoModel(
      movSqlite: 0, // ou algum outro identificador padrão
      movServidor: 0, // ou algum outro identificador padrão
      dataInicio: DateTime.now().toIso8601String(),
      dataModificacao: DateTime.now().toIso8601String(),
      status: 'Inclusão',
      usuario: usuario_logado!, // Substitua pelo usuário real
      origem: '',
      destino: '',
      totalPecas: 0,
      filialOrigem: '',
      filialDestino: '',
      pecas: [],
    );
    notifyListeners();
  }

  // Define a origem e valida contra o destino e peças
  Future<void> setOrigem(String origem) async {
    if (_movimentacaoAtual == null) return;

    if (origem == _movimentacaoAtual!.destino) {
      throw Exception('A origem não pode ser igual ao destino.');
    }

    if (_movimentacaoAtual!.pecas.isNotEmpty) {
      final localizacaoPrimeiraPeca =
          _movimentacaoAtual!.pecas.first.localizacao;
      if (origem != localizacaoPrimeiraPeca) {
        throw Exception(
            'A origem não pode ser diferente da localização atual das peças.');
      }
    }

    _movimentacaoAtual = _movimentacaoAtual!.copyWith(origem: origem);

    if (_movimentacaoAtual?.status == 'Andamento') {
      try {
        final camposParaAtualizar = {
          'origem': origem,
          'data_modificacao': DateTime.now().toIso8601String(),
        };

        await _servMovimentacao.atualizarMovimentacao(
          _movimentacaoAtual!.movServidor,
          camposParaAtualizar,
        );
      } catch (e) {
        // Log de erro (opcional)
        print('Erro ao sincronizar origem no servidor.');
        throw Exception('Erro ao sincronizar origem no servidor: $e');
      }
    }
    notifyListeners();
  }

  // Define o destino e valida contra a origem
  void setDestino(String destino) {
    // if (_movimentacaoAtual == null) return;

    if (destino == _movimentacaoAtual!.origem) {
      throw Exception('O destino não pode ser igual à origem.');
    }

    _movimentacaoAtual = _movimentacaoAtual!.copyWith(destino: destino);
    notifyListeners();
  }

  void setFilialOrigem(String? filialOrigem) {
    if (movimentacaoAtual == null) return;

    _movimentacaoAtual =
        movimentacaoAtual!.copyWith(filialOrigem: filialOrigem);
    notifyListeners();
  }

  void setFilialDestino(String? filialDestino) {
    if (movimentacaoAtual == null) return;

    _movimentacaoAtual =
        movimentacaoAtual!.copyWith(filialDestino: filialDestino);
    notifyListeners();
  }

  // Salva a movimentação (pode ser usada para mover para status "Andamento")
  Future<void> criarMovimentacao() async {
    if (_movimentacaoAtual != null) {
      if (_movimentacaoAtual!.movServidor == 0) {
        _movimentacaoAtual = _movimentacaoAtual!
            .copyWith(movServidor: _movsDoDia.length + 1, status: 'Andamento');
        _movsDoDia.add(_movimentacaoAtual!);
      }
      final mov = movimentacaoAtual!;
      // Log dos dados da movimentação antes de gravar
      print('Dados da movimentação antes de gravar: ${mov.toString()}');

      final db = await _sqlite.bancoDados;
      final movimentacaoMap = {
        'data_inicio': mov.dataInicio,
        'data_modificacao': mov.dataModificacao,
        'status': mov.status,
        'usuario': mov.usuario,
        'origem': mov.origem,
        'destino': mov.destino,
        'total_pecas': mov.totalPecas,
        'filial_origem': mov.filialOrigem,
        'filial_destino': mov.filialDestino,
      };

      // Inserir a movimentação no banco de dados e obter o ID gerado
      int movSqliteId = await db.insert('ESTOQUE_MAT_MOV', movimentacaoMap);
      print('ID da movimentação no SQLite: $movSqliteId');

      // Persistir as peças associadas à movimentação localmente
      for (var peca in mov.pecas) {
        final pecaMap = {
          'peca': peca.peca,
          'material': peca.material,
          'cor_material': peca.corMaterial,
          'partida': peca.partida,
          'unidade': peca.unidade,
          'quantidade': peca.quantidade,
          'mov_sqlite': movSqliteId,
          'desc_material': peca.descMaterial,
          'desc_cor_material': peca.descCorMaterial,
          'localizacao': peca.localizacao,
          'filial': peca.filial,
        };

        await db.insert('ESTOQUE_MAT_MOV_PECA', pecaMap);
      }
      try {
        // Chamar o método para criar a movimentação no servidor
        final response =
            await _servMovimentacao.criarMovimentacao(_movimentacaoAtual!);

        if (response['status'] == 200 || response['status'] == 201) {
          // Atualizar o mov_servidor com o ID retornado do servidor
          int movServidorId = response['data']['mov_servidor'];
          _movimentacaoAtual =
              _movimentacaoAtual!.copyWith(movServidor: movServidorId);

          print('Movimentação atualizada com mov_servidor: $movServidorId');
          // Atualizar o registro no SQLite com o ID do servidor usando o método atualizar
          await _sqlite.atualizar(
            tabela: 'ESTOQUE_MAT_MOV',
            valores: {'mov_servidor': movServidorId},
            whereClausula: {'mov_sqlite': movSqliteId},
          );
        } else {
          print(
              'Erro ao criar movimentação no servidor: ${response['message']}');
        }
      } catch (e) {
        print('Ocorreu um erro: $e');
      }

      notifyListeners();
    }
  }

  // Método no provedor para remover movimentação
  Future removerMovimentacao(MovimentacaoModel mov) async {
    // Determina a coluna e o valor com base no objeto mov
    final int id = mov.movServidor != 0 ? mov.movServidor : mov.movSqlite;
    final String coluna = mov.movServidor != 0 ? 'mov_servidor' : 'mov_sqlite';

    try {
      print('Removendo da coluna: $coluna com valor: $id');

      // Chama o serviço para remover a movimentação no servidor
      final response = await _servMovimentacao.removerMovimentacao(id);
      // Verifica se a remoção no servidor foi bem-sucedida
      if (response['status'] == 200 || response['status'] == 204) {
        // Remover do banco de dados local usando a coluna correta
        await _sqlite.deletar(
          tabela: 'ESTOQUE_MAT_MOV',
          id: {coluna: id},
        );
        // Remover da lista de movimentações do dia
        _movsDoDia.remove(mov);

        notifyListeners();
        return response;
      } else {
        notifyListeners();
        return response;
      }
    } catch (e) {
      notifyListeners();
      throw Exception(e);
    }
  }

  // Finaliza a movimentação
  Future<void> finalizarMovimentacao() async {
    final dataModificacao = DateTime.now().toIso8601String();
    if (_movimentacaoAtual != null &&
        _movimentacaoAtual!.status == 'Andamento') {
      _movimentacaoAtual = _movimentacaoAtual!.copyWith(
        status: 'Finalizada',
        dataModificacao: dataModificacao,
      );

      await _sqlite.atualizar(
        tabela: 'ESTOQUE_MAT_MOV',
        valores: {
          'status': 'Finalizada',
          'data_modificacao': dataModificacao,
        },
        whereClausula: {
          (movimentacaoAtual!.movServidor != null &&
                  movimentacaoAtual!.movServidor != 0)
              ? 'mov_servidor'
              : 'mov_sqlite': (movimentacaoAtual!.movServidor != null &&
                  movimentacaoAtual!.movServidor != 0)
              ? movimentacaoAtual!.movServidor
              : movimentacaoAtual!.movSqlite,
        },
      );

      // Se a movimentação já tem um ID de servidor, sincronizar com o servidor
      if (movimentacaoAtual!.movServidor != null &&
          movimentacaoAtual!.movServidor != 0) {
        try {
          final response = await _servMovimentacao.atualizarMovimentacao(
            movimentacaoAtual!.movServidor!,
            {
              'status': true,
              'data_modificacao': dataModificacao,
            },
          );

          if (response['status'] == 200) {
            print('Movimentação sincronizada com o servidor.');
          } else {
            print(
                'Erro ao sincronizar movimentação com o servidor: ${response['message']}');
          }
        } catch (e) {
          print('Erro ao comunicar com o servidor: $e');
        }
      } else {
        print('Movimentação finalizada apenas localmente.');
      }
    }
  }

  // Método para buscar uma movimentação por ID
  MovimentacaoModel? obterMovimentacaoPorId(int id) {
    try {
      return _movsDoDia.firstWhere(
        (mov) => mov.movServidor == id || mov.movSqlite == id,
      );
    } catch (e) {
      print('Movimentação com ID $id não encontrada: $e');
      return null;
    }
  }

  // Método para definir a movimentação atual
  void setMovimentacaoAtual(MovimentacaoModel movimentacao) {
    _movimentacaoAtual = movimentacao;
    notifyListeners();
  }

  // Método para adicionar peças na movimentação atual
  Future<void> adicionarPeca(Map<String, dynamic> pecaMap) async {
    print(_movimentacaoAtual?.status);
    final dataModificacao =
        DateTime.now().toIso8601String(); // Obtém a data de modificação atual

    if (_movimentacaoAtual == null) return;

    if (_movimentacaoAtual!.status == 'Inclusão') {
      // Operar apenas a nível de instância
      if (_movimentacaoAtual!.origem.isNotEmpty &&
          _movimentacaoAtual!.origem != pecaMap['localizacao']) {
        throw Exception(
            'A peça não pertence a essa origem. \nA peça está em "${pecaMap['localizacao']}".');
      }

      if (_movimentacaoAtual!.pecas.any((p) => p.peca == pecaMap['peca'])) {
        throw Exception('A peça já foi adicionada.');
      }

      _movimentacaoAtual = _movimentacaoAtual!.copyWith(
        pecas: [..._movimentacaoAtual!.pecas, PecaModel.fromJson(pecaMap)],
        totalPecas: _movimentacaoAtual!.totalPecas + 1,
        dataModificacao:
            dataModificacao, // Atualiza a data de modificação localmente
      );
    } else if (_movimentacaoAtual!.status == 'Andamento') {
      // Operar a nível de instância e banco de dados
      if (_movimentacaoAtual!.origem.isNotEmpty &&
          _movimentacaoAtual!.origem != pecaMap['localizacao']) {
        throw Exception(
            'A peça não pertence a essa origem. \nA peça está em "${pecaMap['localizacao']}".');
      }

      if (_movimentacaoAtual!.pecas.any((p) => p.peca == pecaMap['peca'])) {
        throw Exception('A peça já foi adicionada.');
      }

      _movimentacaoAtual = _movimentacaoAtual!.copyWith(
        pecas: [..._movimentacaoAtual!.pecas, PecaModel.fromJson(pecaMap)],
        totalPecas: _movimentacaoAtual!.totalPecas + 1,
        dataModificacao:
            dataModificacao, // Atualiza a data de modificação localmente
      );

      // Operações de banco de dados locais
      pecaMap['mov_sqlite'] = _movimentacaoAtual?.movSqlite;

      await _sqlite.inserir('ESTOQUE_MAT_MOV_PECA', pecaMap);

      await _sqlite.atualizar(
        tabela: 'ESTOQUE_MAT_MOV',
        valores: {
          'total_pecas': movimentacaoAtual!.pecas.length,
          'data_modificacao':
              dataModificacao, // Atualiza a data de modificação no banco de dados local
        },
        whereClausula: {
          (movimentacaoAtual!.movServidor != null &&
                  movimentacaoAtual!.movServidor != 0)
              ? 'mov_servidor'
              : 'mov_sqlite': (movimentacaoAtual!.movServidor != null &&
                  movimentacaoAtual!.movServidor != 0)
              ? movimentacaoAtual!.movServidor
              : movimentacaoAtual!.movSqlite,
        },
      );

      movimentacaoAtual?.totalPecas = movimentacaoAtual!.pecas.length;

      // Sincronizar com o servidor em um bloco try-catch
      try {
        final servicoMovimentacao = ServMovimentacao();
        final response = await servicoMovimentacao.incluirPecas(
          _movimentacaoAtual!.movServidor ?? _movimentacaoAtual!.movSqlite,
          {
            'data_modificacao':
                dataModificacao, // Envia a data de modificação ao servidor
            'pecas': [_movimentacaoAtual!.pecas.last.toJson()],
          },
        );

        if (response['status'] == 201) {
          print('Sincronizado com sucesso.');
        } else {
          print('Erro ao sincronizar com o servidor: ${response['message']}');
        }
      } catch (e) {
        // Captura qualquer erro durante a sincronização com o servidor
        print('Erro ao se comunicar com o servidor: $e');
      }
    }

    notifyListeners();
  }

  // Método para remover peças da movimentação atual
  Future<Map<String, dynamic>> removerPeca(String pecaId) async {
    final int idMov = _movimentacaoAtual!.movServidor != 0
        ? _movimentacaoAtual!.movServidor!
        : _movimentacaoAtual!.movSqlite;
    final String colunaMov =
        _movimentacaoAtual!.movServidor != 0 ? 'mov_servidor' : 'mov_sqlite';
    final String dataModificacao =
        DateTime.now().toIso8601String(); // Data de modificação atual

    try {
      print('Removendo a peça $pecaId da movimentação $idMov ($colunaMov)');

      // Sincroniza a exclusão da peça com o servidor
      final response = await _servMovimentacao.excluirPecas(
        idMov,
        dataModificacao,
        [pecaId], // Envia o ID da peça a ser excluída
      );

      if (response['status'] == 200 || response['status'] == 204) {
        // Se a sincronização for bem-sucedida, remove a peça localmente da movimentação
        _movimentacaoAtual = _movimentacaoAtual!.copyWith(
          pecas: _movimentacaoAtual!.pecas
              .where((peca) => peca.peca != pecaId)
              .toList(),
          totalPecas: _movimentacaoAtual!.totalPecas - 1,
          dataModificacao: dataModificacao,
        );

        // Atualiza o banco de dados local
        await _sqlite.atualizar(
          tabela: 'ESTOQUE_MAT_MOV',
          valores: {
            'total_pecas': _movimentacaoAtual!.pecas.length,
            'data_modificacao':
                dataModificacao, // Atualiza a data de modificação no banco
          },
          whereClausula: {colunaMov: idMov},
        );

        // Remove a peça do banco local
        await _sqlite.deletar(
          tabela: 'ESTOQUE_MAT_MOV_PECA',
          id: {'peca': pecaId}, // Exclui a peça pelo ID
          fk: {
            'mov_sqlite': _movimentacaoAtual!.movSqlite
          }, // Relaciona pela FK
        );

        print('Peça $pecaId removida e sincronizada com sucesso.');
        notifyListeners();
        return response;
      } else {
        // Se falhar, retorna o erro do servidor
        print(
            'Erro ao sincronizar a exclusão com o servidor: ${response['message']}');
        notifyListeners();
        return response;
      }
    } catch (e) {
      notifyListeners();
      throw Exception(e);
    }
  }

  Future<bool> permissaoGravar() async {
    if (movimentacaoAtual == null) {
      throw Exception('Nenhuma movimentação selecionada.');
    }

    final mov = movimentacaoAtual!;

    if (mov.origem.isEmpty) {
      throw Exception('Forneça a origem.');
    }
    if (mov.destino.isEmpty) {
      throw Exception('Forneça o destino.');
    }
    if (mov.totalPecas <= 0 || mov.pecas.isEmpty) {
      throw Exception('Adicione ao menos uma peça.');
    }
    if (mov.status == 'Finalizada') {
      throw Exception('A movimentação já foi finalizada.');
    }

    // Permitir gravar e finalizar se o status for 'Andamento'
    if (mov.status == 'Andamento') {
      return true;
    }

    return true; // Permitir gravar e finalizar em outros estados
  }

  // Limpar o estado atual da movimentação
  Future<void> limparMovimentacaoAtual() async {
    await novaMovimentacao();
    notifyListeners();
  }
}
