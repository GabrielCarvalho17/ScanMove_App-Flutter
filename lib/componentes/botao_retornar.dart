import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/origem_destino.dart';
import 'package:AppEstoqueMP/provedores/usuario.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class BotaoRetornar extends StatelessWidget {
  final VoidCallback onPressed;
  final List<Map<String, dynamic>> pecas;
  final SQLite _dbHelper = SQLite();

  BotaoRetornar({required this.onPressed, required this.pecas});

  Future<void> _salvarMovimentacao(BuildContext context) async {
    final provOrigemDestino = Provider.of<ProvOrigemDestino>(context, listen: false);
    final provUsuario = Provider.of<ProvUsuario>(context, listen: false);

    // Dados da movimentação
    Map<String, dynamic> dadosMovimentacao = {
      'data': DateTime.now().toIso8601String(),
      'usuario': provUsuario.username,
      'origem': provOrigemDestino.origem,
      'destino': provOrigemDestino.destino,
      'total_pecas': pecas.length,
      'status': 'Andamento',
    };

    // Inserir movimentação
    int movimentacaoId = await _dbHelper.inserirEstoqueMatMov(dadosMovimentacao);

    // Inserir peças na tabela ESTOQUE_MAT_MOV_ITEM
    for (var peca in pecas) {
      Map<String, dynamic> dadosPeca = {
        'material': peca['material'],
        'cor_material': peca['cor'],
        'peca': peca['peca'],
        'partida': peca['partida'],
        'unidade': peca['unidade'],
        'quantidade': peca['qtde'],
        'movimentacao': movimentacaoId,
      };
      await _dbHelper.inserirEstoqueMatMovItem(dadosPeca);
    }
  }

  void _mostrarDialogoConfirmacao(BuildContext context) {
    final provOrigemDestino = Provider.of<ProvOrigemDestino>(context, listen: false);
    if (provOrigemDestino.origem.isEmpty || pecas.isEmpty) {
      // Se a origem não foi informada ou não há peças, volta diretamente para a rota 'hist_mov'
      provOrigemDestino.limpar();
      Navigator.of(context).pushReplacementNamed('/hist_mov');
    } else {
      // Se a origem foi informada e há peças, mostra o diálogo de confirmação
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Atenção!',
            mensagem: 'Deseja cancelar a movimentação ou salvar?',
            alturaMinimaTexto: 40,
            textoBotao1: 'Cancelar',
            onBotao1Pressed: () {
              print('Cancelar');
              provOrigemDestino.limpar();
              Navigator.of(context).pop();
              onPressed();
            },
            textoBotao2: 'Salvar',
            onBotao2Pressed: () async {
              print('Salvado');
              await _salvarMovimentacao(context);
              provOrigemDestino.limpar();
              Navigator.of(context).pop();
              onPressed();
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 7, 15, 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1), // Define a borda branca
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextButton.icon(
          onPressed: () {
            _mostrarDialogoConfirmacao(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 25),
          label: Text('Retornar', style: TextStyle(color: Colors.white, fontSize: 16)),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
