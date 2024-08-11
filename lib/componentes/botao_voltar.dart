import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/origem_destino.dart';
import 'package:AppEstoqueMP/provedores/peca.dart';
import 'package:AppEstoqueMP/provedores/usuario.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class BotaoVoltar extends StatelessWidget {
  final List<Map<String, dynamic>> pecas;
  final String? status;
  final int? movimentacaoId;
  final SQLite _dbHelper = SQLite();

  BotaoVoltar({required this.pecas, this.status, this.movimentacaoId});

  Future<void> _salvarMovimentacao(BuildContext context) async {
    final provOrigemDestino = Provider.of<ProvOrigemDestino>(context, listen: false);
    final provUsuario = Provider.of<ProvUsuario>(context, listen: false);

    Map<String, dynamic> dadosMovimentacao = {
      'data': DateTime.now().toIso8601String(),
      'usuario': provUsuario.username,
      'origem': provOrigemDestino.origem,
      'destino': provOrigemDestino.destino,
      'filial_origem': provOrigemDestino.filialOrigem,
      'filial_destino': provOrigemDestino.filialDestino,
      'total_pecas': pecas.length,
      'status': 'Andamento',
    };

    int id = movimentacaoId ?? await _dbHelper.adicionarMovimento(dadosMovimentacao);

    for (var peca in pecas) {
      Map<String, dynamic> dadosPeca = {
        'peca': peca['peca'],
        'material': peca['material'],
        'cor_material': peca['cor'],
        'partida': peca['partida'],
        'unidade': peca['unidade'],
        'quantidade': peca['qtde'],
        'mov_sqlite': id,
        'desc_material': peca['descMaterial'],
        'desc_cor_material': peca['descCor'],
        'localizacao': provOrigemDestino.origem,
        'filial': provOrigemDestino.filialOrigem,
      };
      await _dbHelper.adicionarItem(dadosPeca);
    }
  }

  Future<void> _finalizarMovimentacao(BuildContext context) async {
    if (movimentacaoId != null) {
      await _dbHelper.finalizarMovimento(movimentacaoId!);
    }
  }

  void _mostrarDialogoConfirmacao(BuildContext context) {
    final provOrigemDestino = Provider.of<ProvOrigemDestino>(context, listen: false);
    final provPeca = Provider.of<ProvPeca>(context, listen: false);

    void limparEIrParaHistorico() {
      provOrigemDestino.limpar();
      provPeca.limpar();
      Navigator.of(context).pushReplacementNamed('/hist_mov');
    }

    if (status == 'Finalizada') {
      limparEIrParaHistorico();
    } else if (provOrigemDestino.origem.isEmpty || pecas.isEmpty) {
      limparEIrParaHistorico();
    } else if (status == 'Andamento') {
      if (provOrigemDestino.destino.isEmpty) {
        limparEIrParaHistorico();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogoErro(
              titulo: 'Atenção!',
              mensagem: 'Deseja finalizar a movimentação ou apenas sair?',
              alturaMinimaTexto: 40,
              textoBotao1: 'Sair',
              onBotao1Pressed: () {
                Navigator.of(context).pop();
                limparEIrParaHistorico();
              },
              textoBotao2: 'Finalizar',
              onBotao2Pressed: () async {
                await _finalizarMovimentacao(context);
                Navigator.of(context).pop();
                limparEIrParaHistorico();
              },
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Atenção!',
            mensagem: 'Deseja iniciar uma nova movimentação ou apenas sair?',
            alturaMinimaTexto: 40,
            textoBotao1: 'Sair',
            onBotao1Pressed: () {
              Navigator.of(context).pop();
              limparEIrParaHistorico();
            },
            textoBotao2: 'Salvar',
            onBotao2Pressed: () async {
              await _salvarMovimentacao(context);
              Navigator.of(context).pop();
              limparEIrParaHistorico();
            },
          );
        },
      );
    }
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
