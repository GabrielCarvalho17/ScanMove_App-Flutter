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
    final movimentacaoProvider = Provider.of<ProvMovimentacao>(context, listen: false);
    final movimentacaoAtual = movimentacaoProvider.movimentacaoAtual;

    if (movimentacaoAtual == null) {
      _mostrarResultadoDialogo(context, "Nenhuma movimentação definida.");
      return;
    }

    try {
      final podeGravar = await movimentacaoProvider.permissaoGravar();
      if (!podeGravar) {
        _mostrarResultadoDialogo(
            context,
            "A movimentação não pode ser gravada/finalizada."
        );
        return;
      }

      if (movimentacaoAtual.status == 'Inclusão') {
        final resposta = await _mostrarDialogoConfirmacao(
          context,
          'Deseja gravar e finalizar a movimentação?',
          'Não',
          'Sim',
        );

        if (resposta == true) {
          await movimentacaoProvider.criarMovimentacao();
          movimentacaoProvider.finalizarMovimentacao();
          _mostrarResultadoDialogo(
            context,
            "Movimentação finalizada com sucesso.",
            onDialogClosed: () {
              Navigator.of(context).pop(); // Volta para a tela anterior
              Navigator.of(context).pushNamed('/hist_mov'); // Navega para a tela de histórico
            },
          );
        } else {
          await movimentacaoProvider.criarMovimentacao();
          _mostrarResultadoDialogo(
            context,
            "Movimentação gravada com sucesso.",
          );
        }
      } else if (movimentacaoAtual.status == 'Andamento') {
        final resposta = await _mostrarDialogoConfirmacao(
          context,
          'Deseja finalizar a movimentação?',
          'Não',
          'Sim',
        );

        if (resposta == true) {
          movimentacaoProvider.finalizarMovimentacao();
          _mostrarResultadoDialogo(
            context,
            "Movimentação finalizada com sucesso.",
            onDialogClosed: () {
              Navigator.of(context).pop(); // Volta para a tela anterior
              Navigator.of(context).pushNamed('/hist_mov'); // Navega para a tela de histórico
            },
          );
        } else {
          _mostrarResultadoDialogo(context, "A movimentação não foi finalizada.");
        }
      } else {
        _mostrarResultadoDialogo(context, "Status desconhecido.");
      }
    } catch (e) {
      _mostrarResultadoDialogo(context, e.toString().split(': ').last);
    }
  }

  Future<bool?> _mostrarDialogoConfirmacao(BuildContext context, String mensagem, String textoBotao1, String textoBotao2) {
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

  void _mostrarResultadoDialogo(BuildContext context, String mensagem, {VoidCallback? onDialogClosed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogo(
          titulo: 'Resultado',
          mensagem: mensagem,
          textoBotao2: 'OK',
          onBotao2Pressed: () {
            Navigator.of(context).pop(); // Fecha o diálogo
            if (onDialogClosed != null) {
              onDialogClosed(); // Executa a ação de navegação após o diálogo ser fechado
            }
          },
        );
      },
    );
  }
}
