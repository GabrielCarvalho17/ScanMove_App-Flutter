import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart'; // Importa o diálogo personalizado

class BotaoAdicionarPeca extends StatelessWidget {
  final Object? heroTag;

  const BotaoAdicionarPeca({
    this.heroTag,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final movimentacaoProvider = Provider.of<MovimentacaoProvider>(context, listen: false);

        try {
          // Verifica se a origem foi fornecida
          movimentacaoProvider.setLocalizacaoPeca(null);

          // Se a origem foi fornecida, abre o scanner
          var result = await BarcodeScanner.scan();

          if (result.rawContent.isNotEmpty) {
            movimentacaoProvider.setLocalizacaoPeca(result.rawContent);
            print(movimentacaoProvider.toString());
          }
        } catch (e) {
          // Exibe o diálogo de erro se a origem não foi fornecida
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogo(
                titulo: 'Atenção',
                mensagem: e is Exception ? e.toString().split(': ').last : e.toString(),
              );
            },
          );
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 5,
      heroTag: heroTag,
      child: Icon(
        Icons.add,
        size: 30.0,
        color: Colors.white,
      ),
      tooltip: 'Adicionar Peça',
    );
  }
}
