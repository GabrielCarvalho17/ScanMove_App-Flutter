import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/servicos/peca.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:AppEstoqueMP/provedores/origem_destino.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';

class BotaoAdicionarPeca extends StatelessWidget {
  final Function(Map<String, dynamic>) onPecaAdicionada;

  const BotaoAdicionarPeca({required this.onPecaAdicionada, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProvOrigemDestino>(
      builder: (context, provOrigemDestino, child) {
        return Container(
          width: 55.0,
          height: 55.0,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () async {
                if (provOrigemDestino.origem.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DialogoErro(
                        titulo: 'Atenção',
                        mensagem: 'Por favor, preencha o campo de origem primeiro.',
                      );
                    },
                  );
                } else {
                  Map<String, dynamic>? peca = await _adicionarPeca(context);
                  if (peca != null) {
                    onPecaAdicionada(peca);
                  }
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, size: 30.0),
              shape: const CircleBorder(),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _adicionarPeca(BuildContext context) async {
    final servPeca = ServPeca();

    try {
      final scanResult = await BarcodeScanner.scan();

      // Verifica se o resultado é vazio
      if (scanResult.rawContent.isEmpty) {
        // O usuário cancelou o scan; não faz nada e retorna null
        return null;
      }

      final barcode = scanResult.rawContent;
      if (barcode.isEmpty) {
        throw Exception('Código de barras vazio');
      }

      final pecaModel = await servPeca.fetchPeca(barcode);

      return {
        'peca': pecaModel.peca,
        'partida': pecaModel.partida,
        'material': pecaModel.material,
        'descMaterial': pecaModel.descMaterial,
        'cor': pecaModel.cor,
        'descCor': pecaModel.descCor,
        'unidade': pecaModel.unidade,
        'qtde': pecaModel.qtde,
      };
    } on PecaNotFoundException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Atenção',
            mensagem: e.message,
          );
        },
      );
      return null;
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Erro',
            mensagem: 'Ocorreu um erro ao adicionar a peça.',
          );
        },
      );
      return null;
    }
  }
}
