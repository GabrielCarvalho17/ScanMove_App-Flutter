import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovimentacaoProvider with ChangeNotifier {
  int _movServidor = 0;
  String? _origem;
  String? _filialOrigem;
  String? _destino;
  String? _filialDestino;
  String? _localizacaoPeca;
  String? _statusMovimentacao;
  int _totalPecas = 0;
  String? _usuario;
  String? _dataInicio;
  String? _dataModificacao;
  List<Map<String, dynamic>> _pecas = [];

  // Construtor sem parâmetros
  MovimentacaoProvider();

  // Getters
  int get movServidor => _movServidor;
  String? get origem => _origem;
  String? get destino => _destino;
  String? get filialOrigem => _filialOrigem;
  String? get filialDestino => _filialDestino; // Correção no getter
  String? get localizacaoAtual => _localizacaoPeca;
  String? get statusMovimentacao => _statusMovimentacao;
  int get totalPecas => _totalPecas;
  String? get usuarioAtual => _usuario;
  String? get dataInicio => _dataInicio;
  String? get dataModificacao => _dataModificacao;
  List<Map<String, dynamic>> get pecas => _pecas;

  // Setters com validações
  void setOrigem(String? origem) {
    if (origem == _destino) {
      throw Exception('A origem não pode ser igual ao destino.');
    } else if (_totalPecas > 0 && origem != _localizacaoPeca) {
      throw Exception(
          'A origem não pode ser diferente da localização atual das peças.');
    }
    _origem = origem;
    notifyListeners();
  }

  void setDestino(String? destino) {
    if (destino == _origem) {
      throw Exception('O destino não pode ser igual à origem.');
    }
    _destino = destino;
    notifyListeners();
  }

  void setFilialOrigem(String? filialOrigem) {
    _filialOrigem = filialOrigem;
    notifyListeners();
  }

  void setFilialDestino(String? filialDestino) {
    _filialDestino = filialDestino;
    notifyListeners();
  }

  void setLocalizacaoPeca(String? localizacaoPeca) {
    if (_origem == null) {
      throw Exception('Defina a origem antes de tentar adicionar alguma peça.');
    } else if (localizacaoPeca != null && _origem != localizacaoPeca) {
      throw Exception('A peça não está na localização de origem informada.');
    } else {
      _localizacaoPeca = localizacaoPeca;
      notifyListeners();
    }
  }

  void setTotalPecas(int totalPecas) {
    _totalPecas = totalPecas;
    notifyListeners();
  }

  void setMovServidor(int movServidor) {
    _movServidor = movServidor;
    notifyListeners();
  }

  void setStatusMovimentacao(String? statusMovimentacao) {
    _statusMovimentacao = statusMovimentacao;
    notifyListeners();
  }

  void setDataInicio(String dataInicio) {
    _dataInicio = dataInicio;
    notifyListeners();
  }

  void setDataModificacao(String dataModificacao) {
    _dataModificacao = dataModificacao;
    notifyListeners();
  }

  void adicionarItem(Map<String, dynamic> item) {}

  void setUsuario(String usuario) {
    _usuario = usuario.toLowerCase();
    notifyListeners();
  }

  void setpecas(List<Map<String, dynamic>> list) {
    _pecas = list;
    notifyListeners();
  }

  void permissaoEncerrar() {
    if (_origem == null) {
      throw Exception('Forneça a origem.');
    } else if (_destino == null) {
      throw Exception('Forneça o destino.');
    } else if (_totalPecas <= 0) {
      throw Exception('Adicione ao menos uma peça.');
    } else if (_statusMovimentacao == 'Finalizada') {
      throw Exception('A movimentação já foi finalizada.');
    } else if (_statusMovimentacao != 'Andamento') {
      throw Exception('Grave a movimentação antes de tentar finalizar.');
    }
  }

  Map<String, dynamic> incluirMovmentacao() {
    final dataGravacao = DateTime.now().toIso8601String();
    _dataInicio = dataGravacao;
    _dataModificacao = dataGravacao;
    return {
      "data_inicio": _dataInicio,
      "data_modificacao": _dataModificacao,
      "status": _statusMovimentacao,
      "usuario": _usuario,
      "origem": _origem,
      "destino": _destino,
      "total_pecas": _totalPecas,
      "pecas": _pecas,
    };
  }

  Future<void> limparEstadoAnterior() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuario = prefs.getString('usuario_logado');

    if (usuario != null) {
      setUsuario(usuario);
    }
    _movServidor = 0;
    _origem = null;
    _filialOrigem = null;
    _destino = null;
    _filialDestino = null;
    _localizacaoPeca = null;
    _statusMovimentacao = 'Inclusão';
    _totalPecas = 0;
    _dataInicio = null;
    _dataModificacao = null;
    _pecas.clear();

    notifyListeners();
  }

  @override
  String toString() {
    return '''
MovimentacaoProvider {
  Mov Servidor: $_movServidor,
  Origem: $_origem,
  Destino: $_destino,
  Filial Origem: $_filialOrigem,
  Filial Destino: $_filialDestino,
  Localizacao da Peça: $_localizacaoPeca,
  Status da Movimentação: $_statusMovimentacao,
  Total de Peças: $_totalPecas,
  Usuário: $_usuario,
  Data de Início: $_dataInicio,
  Data de Modificação: $_dataModificacao,
  Peças: ${_formatarPecasIds()}
}
''';
  }

  String _formatarPecasIds() {
    if (_pecas.isEmpty) {
      return '[]';
    }

    final ids = _pecas.map((item) => item['peca']).toList();
    return ids.toString();
  }
}
