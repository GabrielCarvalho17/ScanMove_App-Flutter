import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/servicos/peca.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:AppEstoqueMP/provedores/origem_destino.dart';
import 'package:AppEstoqueMP/provedores/peca.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';

class BotaoAdicionarPeca extends StatelessWidget {
  final Function(Map<String, dynamic>) onPecaAdicionada;
  final Object? heroTag;

  const BotaoAdicionarPeca({required this.onPecaAdicionada, this.heroTag, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProvOrigemDestino>(
      builder: (context, provOrigemDestino, child) {
        return FloatingActionButton(
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
              try {
                final peca = await _adicionarPeca(context, provOrigemDestino.origem);
                if (peca != null) {
                  onPecaAdicionada(peca);
                  Provider.of<ProvPeca>(context, listen: false).setUltimaPeca(
                      peca['localizacao'], peca['filial']);
                }
              } catch (e) {
                String mensagemErro;
                if (e is PecaNotFoundException) {
                  mensagemErro = e.message;
                } else if (e.toString().contains('O servidor não está respondendo.')) {
                  mensagemErro = 'O servidor não está respondendo. Tente novamente mais tarde.';
                } else {
                  mensagemErro = 'Ocorreu um erro ao adicionar a peça.';
                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DialogoErro(
                      titulo: 'Erro',
                      mensagem: mensagemErro,
                    );
                  },
                );
              }
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
      },
    );
  }

  Future<Map<String, dynamic>?> _adicionarPeca(
      BuildContext context, String origem) async {
    final servPeca = ServPeca();

    try {
      final scanResult = await BarcodeScanner.scan();
      print('Resultado do scan: ${scanResult.rawContent}');

      if (scanResult.rawContent.isEmpty) {
        print('Código de barras vazio.');
        return null;
      }

      final barcode = scanResult.rawContent;
      if (barcode.isEmpty) {
        throw Exception('Código de barras vazio');
      }

      final pecaModel = await servPeca.fetchPeca(context, barcode);
      print('Modelo de peça: ${pecaModel.toString()}');

      if (pecaModel.localizacao != origem) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogoErro(
              titulo: 'Atenção',
              mensagem: 'A localização da peça não corresponde à origem.',
            );
          },
        );
        return null;
      }

      return {
        'peca': pecaModel.peca,
        'partida': pecaModel.partida,
        'material': pecaModel.material,
        'descMaterial': pecaModel.descMaterial,
        'cor': pecaModel.cor,
        'descCor': pecaModel.descCor,
        'localizacao': pecaModel.localizacao,
        'filial': pecaModel.filial,
        'unidade': pecaModel.unidade,
        'qtde': pecaModel.qtde,
      };
    } on PecaNotFoundException catch (e) {
      throw e; // Passa a exceção adiante para o bloco catch
    } catch (e) {
      throw Exception('Ocorreu um erro ao adicionar a peça: $e');
    }
  }
}
