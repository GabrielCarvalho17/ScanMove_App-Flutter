import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BotaoVoltar extends StatelessWidget {
  BotaoVoltar({Key? key}) : super(key: key);

  void _mostrarDialogoConfirmacao(BuildContext context) async {
    // Removida a lógica de provedor e SQLite
    Navigator.of(context).pop(); // Volta para a tela anterior
    final movimentacaoProvider =
        Provider.of<MovimentacaoProvider>(context, listen: false);
    await movimentacaoProvider.verificarERecarregarMovs();
    print(movimentacaoProvider.toString());
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        _mostrarDialogoConfirmacao(context);
      },
    );
  }
}
