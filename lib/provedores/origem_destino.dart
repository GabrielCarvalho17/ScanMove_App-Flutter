import 'package:flutter/material.dart';

class ProvOrigemDestino extends ChangeNotifier {
  String _origem = '';
  String _destino = '';

  String get origem => _origem;
  String get destino => _destino;

  void setOrigem(String origem) {
    _origem = origem;
    notifyListeners();
  }

  void setDestino(String destino) {
    _destino = destino;
    notifyListeners();
  }
}
