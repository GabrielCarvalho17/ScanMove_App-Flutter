import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'telas/login.dart';
import 'telas/hist_mov.dart';
import 'telas/nova_mov.dart';
import 'provedores/usuario.dart';

class Rotas {
  static const String login = '/login';
  static const String histMov = '/hist_mov';
  static const String novaMov = '/nova_mov';

  static Route<dynamic> gerarRota(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) {
      final provUsuario = Provider.of<ProvUsuario>(context, listen: false);

      // Redireciona para a tela de login se o usuário não estiver autenticado
      if (provUsuario.token.isEmpty && settings.name != login) {
        return Login();
      }

      final args = settings.arguments as Map<String, dynamic>?;

      switch (settings.name) {
        case login:
          return Login();
        case histMov:
          return HistMov();
        case novaMov:
          return NovaMov(
            id: args?['id'],
          );
        default:
          return HistMov();
      }
    });
  }
}
