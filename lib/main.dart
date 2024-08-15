import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/usuario.dart';
import 'package:AppEstoqueMP/provedores/movimentacao.dart';  // Importa o MovimentacaoProvider
import 'rotas.dart';
import 'tema.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final provUsuario = ProvUsuario();
  await provUsuario.loadUserOnInit();

  runApp(MyApp(provUsuario: provUsuario));
}

class MyApp extends StatelessWidget {
  final ProvUsuario provUsuario;

  MyApp({required this.provUsuario});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: provUsuario),
        ChangeNotifierProvider(create: (_) => MovimentacaoProvider()),  // Adiciona o MovimentacaoProvider
      ],
      child: MaterialApp(
        title: 'App Estudo',
        theme: AppTheme.theme,
        initialRoute: provUsuario.token.isEmpty ? '/login' : '/hist_mov',
        onGenerateRoute: Rotas.gerarRota,
      ),
    );
  }
}
