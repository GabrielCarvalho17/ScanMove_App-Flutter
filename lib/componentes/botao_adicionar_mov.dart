import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:AppEstoqueMP/modelos/movimentacao.dart';

class BotaoAdicionarMov extends StatelessWidget {
  final Object? heroTag;

  BotaoAdicionarMov({this.heroTag});

  // Método que realiza as ações desejadas
  void _adicionarMovimentacao(BuildContext context) async {
    final movimentacaoProvider =
        Provider.of<MovimentacaoProvider>(context, listen: false);

    // Tenta encontrar uma movimentação com status 'Andamento'
    MovimentacaoModel? movAndamento;
    try {
      movAndamento = movimentacaoProvider.movsDoDia.firstWhere(
        (mov) => mov.status == 'Andamento',
      );
    } catch (e) {
      movAndamento = null;
    }

    if (movAndamento != null) {
      // Exibe o CustomDialogo informando o usuário
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogo(
            titulo: 'Atenção',
            mensagem:
                'Você já possui uma movimentação em andamento.\n\nFinalize primeiro para iniciar outra.',
            onBotao1Pressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else {
      // Se não houver movimentação em andamento, cria uma nova
      Navigator.pushNamed(context, '/nova_mov');
      await movimentacaoProvider.limparEstadoAnterior();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () =>
          _adicionarMovimentacao(context), // Chama o método da classe
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      heroTag: heroTag, // Utiliza a tag hero única
      child: Center(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
