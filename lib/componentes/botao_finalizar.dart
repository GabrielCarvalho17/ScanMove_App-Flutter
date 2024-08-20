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
      onPressed: () => _finalizarMovimentacao(context),
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

  Future<void> _finalizarMovimentacao(BuildContext context) async {
    final movimentacaoProvider =
    Provider.of<MovimentacaoProvider>(context, listen: false);
    final movimentacaoAtual = movimentacaoProvider.movimentacaoAtual;

    if (movimentacaoAtual == null) {
      _mostrarResultadoDialogo(context, {
        "status": "erro",
        "mensagem": "Nenhuma movimentação definida.",
      });
      return;
    }

    try {
      final podeGravar = await movimentacaoProvider.permissaoGravar();

      if (!podeGravar) {
        return; // Não permitir continuar se não puder gravar
      }

      if (movimentacaoAtual.status == 'Inclusão') {
        final resposta = await _mostrarDialogoConfirmacao(
          context,
          'Deseja iniciar uma nova movimentação?',
          'Não',
          'Sim',
        );

        if (resposta == true) {
          await movimentacaoProvider.gravarFinalizar();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogo(
                titulo: 'Sucesso',
                mensagem: "Movimentação gravada com sucesso.",
                textoBotao2: 'OK',
                onBotao2Pressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
              );
            },
          ).then((_) async {
            // Esta parte é executada após o diálogo ser fechado
            Navigator.of(context).pop(); // Volta para a tela anterior
            await movimentacaoProvider.verificarERecarregarMovs();
            await movimentacaoProvider.limparEstadoAnterior();
            print(movimentacaoProvider.toString());
          });
        }

      } else if (movimentacaoAtual.status == 'Andamento') {
        final resposta = await _mostrarDialogoConfirmacao(
          context,
          'Deseja finalizar a movimentação em andamento?',
          'Não',
          'Sim',
        );

        if (resposta == true) {
          await movimentacaoProvider.gravarFinalizar();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogo(
                titulo: 'Sucesso',
                mensagem: "Movimentação finalizada com sucesso.",
                textoBotao1: 'OK',
                onBotao1Pressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
              );
            },
          ).then((_) async {
            // Esta parte é executada após o diálogo ser fechado
            Navigator.of(context).pop(); // Volta para a tela anterior
            await movimentacaoProvider.verificarERecarregarMovs();
            await movimentacaoProvider.limparEstadoAnterior();
            print(movimentacaoProvider.toString());
          });
        }
      }
    } catch (e) {
      _mostrarResultadoDialogo(context, {
        "status": "erro",
        "mensagem":
        e.toString().split(': ').last, // Remove o prefixo "Exception: "
      });
    }
  }

  Future<bool?> _mostrarDialogoConfirmacao(BuildContext context,
      String mensagem, String textoBotao1, String textoBotao2) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogo(
          titulo: 'Confirmação',
          mensagem: mensagem,
          textoBotao1: textoBotao1,
          onBotao1Pressed: () => Navigator.of(context).pop(false),
          textoBotao2: textoBotao2,
          onBotao2Pressed: () => Navigator.of(context).pop(true),
        );
      },
    );
  }

  void _mostrarResultadoDialogo(
      BuildContext context, Map<String, String> resultado) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogo(
          titulo: resultado["status"] == "sucesso" ? 'Sucesso' : 'Atenção',
          mensagem: resultado["mensagem"]!,
          textoBotao1: resultado['Ok'],
          onBotao1Pressed: resultado['Ok'] != null
              ? () {
            Navigator.of(context).pop(); // Volta para a tela anterior
          }
              : null,
        );
      },
    );
  }




}
