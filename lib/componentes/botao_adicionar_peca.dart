import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:AppEstoqueMP/servicos/peca.dart'; // Importa o serviço ServPeca
import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';

class BotaoAdicionarPeca extends StatelessWidget {
  final Object? heroTag;

  const BotaoAdicionarPeca({
    this.heroTag,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _adicionarPeca(context),
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

  Future<void> _adicionarPeca(BuildContext context) async {
    final movimentacaoProvider =
    Provider.of<ProvMovimentacao>(context, listen: false);
    final servicoPeca = ServPeca(); // Instancia o serviço
    bool loadingExibido = false;
    Timer? timer;

    // Captura o tempo inicial
    final inicio = DateTime.now();

    try {
      var result = await BarcodeScanner.scan();

      if (result.rawContent.isNotEmpty) {
        // Exibe o dialogo de loading após 1 segundo
        timer = Timer(Duration(seconds: 1), () {
          loadingExibido = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogo(
                titulo: 'Aguarde',
                mensagem: 'Processando, por favor aguarde...',
                isLoading: true,
              );
            },
          );
        });

        // Chama o serviço para buscar a peça
        var resultado = await servicoPeca.fetchPeca(result.rawContent);

        // Cancela o timer e fecha o loading se estiver ativo
        if (timer != null && timer.isActive) {
          timer.cancel();
        }
        if (loadingExibido && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        // Verifica o resultado do serviço
        if (resultado['status'] == 200) {
          final peca = resultado['peca'];
          await movimentacaoProvider.adicionarPeca(peca.toJson());
          print(peca.toJson());
        } else {
          _mostrarDialogoErro(
              context, 'Erro', resultado['message'] ?? 'Erro desconhecido');
        }
      }
    } catch (e) {
      if (loadingExibido && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _mostrarDialogoErro(context, 'Erro', 'Ocorreu um erro: ${e.toString()}');
    } finally {
      // Captura o tempo final e calcula a duração
      final fim = DateTime.now();
      final duracao = fim.difference(inicio);

      // Imprime o tempo que a operação levou em segundos
      print("A operação levou: ${duracao.inSeconds} segundos");
    }
  }


  void _mostrarDialogoErro(
      BuildContext context, String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogo(
          titulo: titulo,
          mensagem: mensagem,
        );
      },
    );
  }
}
