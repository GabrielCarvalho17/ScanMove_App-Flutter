import 'package:flutter/material.dart';
import 'telas/login.dart';
import 'telas/hist_mov.dart';
import 'telas/nova_mov.dart';

class Rotas {
  static const String login = '/login';
  static const String histMov = '/hist_mov';
  static const String novaMov = '/nova_mov';

  static Route<dynamic> gerarRota(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => Login());
      case histMov:
        return MaterialPageRoute(builder: (_) => HistMov());
      case novaMov:
        return MaterialPageRoute(builder: (_) => NovaMov(
          id: args?['id'],
          status: args?['status'],
        ));
      default:
        return MaterialPageRoute(builder: (_) => HistMov());
    }
  }
}


