import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:AppEstoqueMP/servicos/movimentacao.dart';
import 'package:AppEstoqueMP/modelos/movimentacao.dart';
import 'package:AppEstoqueMP/modelos/peca.dart';

class MovimentacaoProvider with ChangeNotifier {
  final SQLite _sqlite = SQLite();
  final ServMovimentacao _servMovimentacao = ServMovimentacao();

  MovimentacaoModel? _movimentacaoAtual;
  List<MovimentacaoModel> _movsDoDia = [];
  bool _isLoading = true;
  String? _ultimaCarga;

  // Getters para o estado atual e lista de movimentações
  String? _usuarioAtual;
  MovimentacaoModel? get movimentacaoAtual => _movimentacaoAtual;
  List<MovimentacaoModel> get movsDoDia => _movsDoDia;
  bool get isLoading => _isLoading;
  String? get ultimaCarga => _ultimaCarga;

  // Verificar se o usuário está logado
  Future<bool> _isUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    _usuarioAtual = prefs.getString('usuario_logado');
    return _usuarioAtual != null;
  }

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
      } else {
        throw Exception('Erro ao carregar movimentações.');
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

// Remover movimentação
  Future<void> removerMovimentacao(int movServidor) async {
    try {
      // Remover do banco de dados usando a coluna correta
      await _sqlite.deletar('ESTOQUE_MAT_MOV', movServidor,
          column: 'mov_servidor');

      // Remover do provedor (lista de movimentações do dia)
      _movsDoDia.removeWhere((mov) => mov.movServidor == movServidor);

      notifyListeners();
    } catch (e) {
      // Log de erro (opcional)
      print('Erro ao remover movimentação: $e');
      throw Exception('Erro ao remover movimentação.');
    }
  }

  // Definir movimentação atual
  void setMovimentacaoAtual(MovimentacaoModel movimentacao) {
    _movimentacaoAtual = movimentacao;
    notifyListeners();
  }

  Future<bool> permissaoGravar() async {
    if (movimentacaoAtual == null) {
      throw Exception('Nenhuma movimentação selecionada.');
    }

    final mov = movimentacaoAtual!;

    if (mov.origem == null || mov.origem!.isEmpty) {
      throw Exception('Forneça a origem.');
    }
    if (mov.destino == null || mov.destino!.isEmpty) {
      throw Exception('Forneça o destino.');
    }
    if (mov.totalPecas <= 0 || mov.pecas.isEmpty) {
      throw Exception('Adicione ao menos uma peça.');
    }
    if (mov.status == 'Finalizada') {
      throw Exception('A movimentação já foi finalizada.');
    }
    if (mov.status != 'Andamento') {
      print(mov.status);
      return true; // Permitir gravar e finalizar
    }

    return false; // Não permitir gravar e finalizar
  }

  Future<void> gravarFinalizar() async {
    if (movimentacaoAtual == null) {
      throw Exception('Nenhuma movimentação selecionada.');
    }

    final mov = movimentacaoAtual!;

    // Persistir a movimentação no banco de dados
    final db = await _sqlite.bancoDados;
    final movimentacaoMap = {
      'data_inicio': mov.dataInicio,
      'data_modificacao': mov.dataModificacao,
      'status': 'Andamento',
      'usuario': mov.usuario,
      'origem': mov.origem,
      'destino': mov.destino,
      'total_pecas': mov.totalPecas,
      'mov_servidor': mov.movServidor,
      'filial_origem': mov.filialOrigem,
      'filial_destino': mov.filialDestino,
    };

    int movSqliteId = await db.insert('ESTOQUE_MAT_MOV', movimentacaoMap);

    // Persistir as peças associadas à movimentação
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

    // Atualizar o estado da movimentação
    _movimentacaoAtual = mov.copyWith(movSqlite: movSqliteId);
    notifyListeners();
  }

  MovimentacaoModel? getMovimentacaoPorId(int id) {
    try {
      return _movsDoDia.firstWhere(
        (mov) => mov.movServidor == id || mov.movSqlite == id,
      );
    } catch (e) {
      return null;
    }
  }

  void setOrigem(String? origem) {
    if (movimentacaoAtual == null) return;

    if (origem == movimentacaoAtual!.destino) {
      throw Exception('A origem não pode ser igual ao destino.');
    }

    if (movimentacaoAtual!.pecas.isNotEmpty) {
      final localizacaoPrimeiraPeca =
          movimentacaoAtual!.pecas.first.localizacao;
      if (origem != localizacaoPrimeiraPeca) {
        throw Exception(
            'A origem não pode ser diferente da localização atual das peças.');
      }
    }

    _movimentacaoAtual = movimentacaoAtual!.copyWith(origem: origem);
    notifyListeners();
  }

  void setDestino(String? destino) {
    if (movimentacaoAtual == null) return;

    if (destino == movimentacaoAtual!.origem) {
      throw Exception('O destino não pode ser igual à origem.');
    }

    _movimentacaoAtual = movimentacaoAtual!.copyWith(destino: destino);
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

  void adicionarPeca(Map<String, dynamic> pecaMap) {
    if (movimentacaoAtual == null) return;

    // Converte o mapa para uma instância de PecaModel
    final novaPeca = PecaModel.fromJson(pecaMap);

    // Verifica se a origem foi definida e se a localização da peça corresponde à origem
    if (movimentacaoAtual!.origem != null &&
        movimentacaoAtual!.origem!.isNotEmpty &&
        movimentacaoAtual!.origem != novaPeca.localizacao) {
      throw Exception(
          'A peça não pertence a essa origem. \nA peça está em "${novaPeca.localizacao}".');
    }

    if (movimentacaoAtual!.pecas.any((p) => p.peca == novaPeca.peca)) {
      throw Exception('A peça já foi adicionada.');
    }

    _movimentacaoAtual = movimentacaoAtual!.copyWith(
      pecas: [...movimentacaoAtual!.pecas, novaPeca],
      totalPecas: movimentacaoAtual!.totalPecas + 1,
    );

    notifyListeners();

    // Persistir a adição da peça no banco de dados se necessário
    if (_movimentacaoAtual!.movSqlite != null) {
      _sqlite.inserir('ESTOQUE_MAT_MOV_PECA', {
        ...pecaMap,
        'mov_sqlite': _movimentacaoAtual!.movSqlite,
      });
    }
  }

  void removerPeca(String pecaId) {
    if (_movimentacaoAtual != null) {
      _movimentacaoAtual = _movimentacaoAtual!.copyWith(
        pecas: _movimentacaoAtual!.pecas
            .where((peca) => peca.peca != pecaId)
            .toList(),
        totalPecas: _movimentacaoAtual!.totalPecas - 1,
      );
    }

    notifyListeners();
  }

  // Limpar o estado atual
  Future<void> limparEstadoAnterior() async {
    final prefs = await SharedPreferences.getInstance();

    String? usuario = prefs.getString('usuario_logado');
    _movimentacaoAtual = MovimentacaoModel(
      movServidor: 0,
      dataInicio: DateTime.now().toIso8601String(),
      dataModificacao: DateTime.now().toIso8601String(),
      status: 'Inclusão',
      usuario: usuario ?? '',
      origem: '',
      destino: '',
      totalPecas: 0,
      filialOrigem: '',
      filialDestino: '',
      pecas: [],
    );

    notifyListeners();
  }

  @override
  String toString() {
    String dataAtual = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return '''
Movimentacao Atual {
  Usuario Atual: $_usuarioAtual,
  Últ. Carga: $_ultimaCarga,
  Data Atual: $dataAtual,
  Movimentação: $_movimentacaoAtual,
  Movs do Dia: $_movsDoDia
}
''';
  }
}
