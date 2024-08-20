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
        Provider.of<MovimentacaoProvider>(context, listen: false);
    final servicoPeca = ServPeca();
    bool loadingExibido = false;
    Timer? timer;

    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
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

        var resultado = await servicoPeca.fetchPeca(result.rawContent);

        if (timer != null && timer.isActive) {
          timer.cancel();
        }

        if (loadingExibido && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        switch (resultado['status']) {
          case StatusPeca.sucesso:
            final peca = resultado['peca'];
            await movimentacaoProvider.adicionarPeca(peca.toJson());
            print(peca.toJson());
            print(movimentacaoProvider.toString());
            break;
          case StatusPeca.timeout:
            _mostrarDialogoErro(context, 'Erro',
                'O servidor não está respondendo no momento. Tente novamente mais tarde.');
            break;
          case StatusPeca.semConexao:
            _mostrarDialogoErro(context, 'Erro',
                'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.');
            break;
          case StatusPeca.pecaNaoEncontrada:
            _mostrarDialogoErro(context, 'Atenção', 'Peça não encontrada.');
            break;
          case StatusPeca.erroServidor:
          default:
            _mostrarDialogoErro(context, 'Erro',
                'Erro ao buscar dados da peça. Tente novamente mais tarde.');
            break;
        }
      }
    } catch (e) {
      if (loadingExibido && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _mostrarDialogoErro(context, 'Erro', e.toString().split(': ').last);
    } finally {
      if (loadingExibido && Navigator.canPop(context)) {
        Navigator.of(context).pop();
        _mostrarDialogoErro(context, 'Erro',
            'O servidor não está respondendo no momento. Tente novamente mais tarde.');
      }
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
