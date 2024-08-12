import 'package:flutter/material.dart';

class ProvPeca extends ChangeNotifier {
  String _ultimaLocalizacao = '';
  String _ultimaFilial = '';
  int _contadorPecas = 0;

  String get ultimaLocalizacao => _ultimaLocalizacao;
  int get contadorPecas => _contadorPecas;
  String get ultimaFilial => _ultimaFilial;

  void setUltimaPeca(String localizacao, String filial) {
    _ultimaLocalizacao = localizacao;
    _ultimaFilial = filial;
    notifyListeners();
  }

  void limpar() {
    _ultimaLocalizacao = '';
    _ultimaFilial = '';
    notifyListeners();
  }

  void setContadorPeca() {
    _contadorPecas += 1;
    notifyListeners();
  }

  void inicializarContadorPeca(int total) {
    _contadorPecas = total;
    notifyListeners();
  }
}
