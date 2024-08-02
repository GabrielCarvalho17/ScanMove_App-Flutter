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
    notifyListeners();
  }

  void setDestino(String destino, {String filial = ''}) {
    _destino = destino;
    _filialDestino = filial;
    notifyListeners();
  }

  void limpar() {
    _origem = '';
    _destino = '';
    _filialOrigem = '';
    _filialDestino = '';
    notifyListeners();
  }
}
