import 'package:flutter/material.dart';

class ProvOrigemDestino extends ChangeNotifier {
  String _origem = '';
  String _destino = '';
  String _filialOrigem = '';
  String _filialDestino = '';

  String get origem => _origem;
  String get destino => _destino;
  String get filialOrigem => _filialOrigem;
  String get filialDestino => _filialDestino;

  void setOrigem(String origem, {String filial = ''}) {
    _origem = origem;
    _filialOrigem = filial;
    _logEstadoAtual();  // Adiciona print aqui
    notifyListeners();
  }

  void setDestino(String destino, {String filial = ''}) {
    _destino = destino;
    _filialDestino = filial;
    _logEstadoAtual();  // Adiciona print aqui
    notifyListeners();
  }

  void inicializarOrigemDestino(String origem, String destino, {String filialOrigem = '', String filialDestino = ''}) {
    _origem = origem;
    _filialOrigem = filialOrigem;
    _destino = destino;
    _filialDestino = filialDestino;
    _logEstadoAtual();  // Adiciona print aqui
    notifyListeners();
  }

  void limpar() {
    _origem = '';
    _destino = '';
    _filialOrigem = '';
    _filialDestino = '';
    _logEstadoAtual();  // Adiciona print aqui
    notifyListeners();
  }

  void _logEstadoAtual() {
    print('Origem: $_origem, Filial Origem: $_filialOrigem, Destino: $_destino, Filial Destino: $_filialDestino');
  }
}
