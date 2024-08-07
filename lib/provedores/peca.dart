import 'package:flutter/material.dart';

class ProvPeca extends ChangeNotifier {
  String _ultimaLocalizacao = '';
  String _ultimaFilial = '';

  String get ultimaLocalizacao => _ultimaLocalizacao;
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
}
