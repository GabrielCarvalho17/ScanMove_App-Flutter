import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';

class BotaoFinalizar extends StatelessWidget {
  final Object? heroTag;

  BotaoFinalizar({required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final movimentacaoProvider =
        Provider.of<MovimentacaoProvider>(context, listen: false);
        try {
          movimentacaoProvider.permissaoEncerrar();
          // Se chegou aqui, significa que a movimentação pode ser finalizada
          // Aqui você pode adicionar a lógica real de finalização, como mudar o status ou salvar no banco de dados

          // Exibe o diálogo de sucesso
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogo(
                titulo: 'Sucesso',
                mensagem: 'Movimentação finalizada com sucesso!',
              );
            },
          );
        } catch (e) {
          // Em caso de erro, exibe o diálogo de erro
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogo(
                titulo: 'Atenção',
                mensagem: e
                    .toString()
                    .split(': ')
                    .last, // Remove o prefixo "Exception: "
              );
            },
          );
        }
      },
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 5,
      heroTag: heroTag,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      tooltip: 'Finalizar',
    );
  }
}
