import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/origem_destino.dart';
import 'package:AppEstoqueMP/provedores/peca.dart';
import 'package:AppEstoqueMP/provedores/usuario.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class BotaoRetornar extends StatelessWidget {
  final List<Map<String, dynamic>> pecas;
  final String? status;
  final int? movimentacaoId;
  final SQLite _dbHelper = SQLite();

  BotaoRetornar({required this.pecas, this.status, this.movimentacaoId});

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

    // Adiciona os itens relacionados a esta movimentação
    for (var peca in pecas) {
      Map<String, dynamic> dadosPeca = {
        'peca': peca['peca'],
        'material': peca['material'],
        'cor_material': peca['cor'],
        'partida': peca['partida'],
        'unidade': peca['unidade'],
        'quantidade': peca['qtde'],
        'mov_sqlite': id, // Associando corretamente ao ID da movimentação
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Atenção!',
            mensagem: 'Deseja cancelar a movimentação ou salvar?',
            alturaMinimaTexto: 40,
            textoBotao1: 'Cancelar',
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            _mostrarDialogoConfirmacao(context);
          },
          child: CircleAvatar(
            radius: 20, // Ajuste o tamanho do botão circular
            backgroundColor: Colors.white, // Cor de fundo do botão
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary, // Cor do ícone
              size: 24, // Ajuste o tamanho do ícone
            ),
          ),
        ),
        SizedBox(height: 4), // Ajuste o espaçamento entre o ícone e o texto
        Text(
          'Retornar',
          style: TextStyle(color: Colors.white, fontSize: 14), // Ajuste o tamanho do texto
        ),
      ],
    );
  }
}
