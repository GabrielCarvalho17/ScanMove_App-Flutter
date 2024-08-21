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

  // Remover movimentação
  Future<void> removerMovimentacao(Map<String, int> idInfo) async {
    try {
      // Extrai a chave e o valor do mapa
      final String coluna = idInfo.keys.first;
      final int valor = idInfo.values.first;

      print('Removendo da coluna: $coluna com valor: $valor');

      // Remover do banco de dados usando a coluna correta
      await _sqlite.deletar(
        tabela: 'ESTOQUE_MAT_MOV',
        id: {coluna: valor},
      );

      // Remover do provedor (lista de movimentações do dia)
      if (coluna == 'mov_servidor') {
        _movsDoDia.removeWhere((mov) => mov.movServidor == valor);
      } else if (coluna == 'mov_sqlite') {
        _movsDoDia.removeWhere((mov) => mov.movSqlite == valor);
      }

      notifyListeners();
    } catch (e) {
      // Log de erro (opcional)
      print('Erro ao remover movimentação: $e');
      throw Exception('Erro ao remover movimentação.');
    }
  }


  // Define a origem e valida contra o destino e peças
  void setOrigem(String origem) {
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
  Future<void> salvarMovimentacao() async {
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
      notifyListeners();
    }
  }

// Finaliza a movimentação
  Future<void> finalizarMovimentacao() async {
    if (_movimentacaoAtual != null &&
        _movimentacaoAtual!.status == 'Andamento') {
      _movimentacaoAtual = _movimentacaoAtual!.copyWith(
        status: 'Finalizada',
        dataModificacao: DateTime.now().toIso8601String(),
      );

      await _sqlite.atualizar(
        'ESTOQUE_MAT_MOV',
        {'status': 'Finalizada'},
        column: (movimentacaoAtual!.movServidor != null &&
                movimentacaoAtual!.movServidor != 0)
            ? 'mov_servidor'
            : 'mov_sqlite',
        valor: (movimentacaoAtual!.movServidor != null &&
                movimentacaoAtual!.movServidor != 0)
            ? movimentacaoAtual!.movServidor
            : movimentacaoAtual!.movSqlite,
      );

      print(movimentacaoAtual?.movServidor);
      notifyListeners();
    }
  }

  // Método para buscar uma movimentação por ID
  MovimentacaoModel? getMovimentacaoPorId(int id) {
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

  // Adiciona uma peça à movimentação e valida
  Future<void> adicionarPeca(Map<String, dynamic> pecaMap) async {
    print(_movimentacaoAtual?.status);

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
      );

      // Operações de banco de dados
      pecaMap['mov_sqlite'] = _movimentacaoAtual?.movSqlite;

      await _sqlite.inserir('ESTOQUE_MAT_MOV_PECA', pecaMap);

      await _sqlite.atualizar(
        'ESTOQUE_MAT_MOV',
        {'total_pecas': movimentacaoAtual!.pecas.length},
        column: (movimentacaoAtual!.movServidor != null &&
                movimentacaoAtual!.movServidor != 0)
            ? 'mov_servidor'
            : 'mov_sqlite',
        valor: (movimentacaoAtual!.movServidor != null &&
                movimentacaoAtual!.movServidor != 0)
            ? movimentacaoAtual!.movServidor
            : movimentacaoAtual!.movSqlite,
      );

      movimentacaoAtual?.totalPecas = movimentacaoAtual!.pecas.length;
    }

    notifyListeners();
  }

  Future<void> removerPeca(String pecaId) async {
    print(_movimentacaoAtual?.status);

    if (_movimentacaoAtual == null) return;

    if (_movimentacaoAtual!.status == 'Inclusão') {
      _movimentacaoAtual = _movimentacaoAtual!.copyWith(
        pecas: _movimentacaoAtual!.pecas
            .where((peca) => peca.peca != pecaId)
            .toList(),
        totalPecas: _movimentacaoAtual!.totalPecas - 1,
      );
    } else if (_movimentacaoAtual?.status == 'Andamento') {

      movimentacaoAtual?.totalPecas = movimentacaoAtual!.pecas.length;

      _movimentacaoAtual = _movimentacaoAtual!.copyWith(
        pecas: _movimentacaoAtual!.pecas
            .where((peca) => peca.peca != pecaId)
            .toList(),
        totalPecas: _movimentacaoAtual!.totalPecas - 1,
      );


      await _sqlite.deletar(
        tabela: 'ESTOQUE_MAT_MOV_PECA',
        id: {'peca': pecaId},  // Mapa para o ID
        fk: {'mov_sqlite': movimentacaoAtual!.movSqlite},  // Mapa opcional para a FK
      );

      await _sqlite.atualizar(
        'ESTOQUE_MAT_MOV',
        {'total_pecas': movimentacaoAtual!.pecas.length},
        column: (movimentacaoAtual!.movServidor != null &&
            movimentacaoAtual!.movServidor != 0)
            ? 'mov_servidor'
            : 'mov_sqlite',
        valor: (movimentacaoAtual!.movServidor != null &&
            movimentacaoAtual!.movServidor != 0)
            ? movimentacaoAtual!.movServidor
            : movimentacaoAtual!.movSqlite,
      );

    }
    notifyListeners();
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
