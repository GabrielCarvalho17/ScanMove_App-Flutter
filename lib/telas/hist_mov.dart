import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:AppEstoqueMP/componentes/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/botao_adicionar_mov.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';  // Importar o dialogo

class HistMov extends StatefulWidget {
  @override
  _HistMovState createState() => _HistMovState();
}

class _HistMovState extends State<HistMov> {
  List<Map<String, dynamic>> movimentacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarMovimentacoes();
  }

  Future<void> _carregarMovimentacoes() async {
    final db = SQLite();
    final movs = await db.obterMovimentos();
    setState(() {
      movimentacoes = movs;
    });
  }

  void _deletarMovimentacao(int id) async {
    final db = SQLite();
    await db.deletarMovimento(id);
    _carregarMovimentacoes(); // Recarrega as movimentações após a exclusão
  }

  Future<bool> _confirmDismiss(BuildContext context, Map<String, dynamic> mov) async {
    if (mov['status'] == 'Finalizada') {
      // Exibe o diálogo de erro se o status for 'Finalizada'
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Ação Impossível',
            mensagem: 'Não é possível excluir uma movimentação finalizada.',
          );
        },
      );
      return false; // Não permite a exclusão
    }

    bool shouldDelete = false;

    // Exibe o diálogo de confirmação se o status não for 'Finalizada'
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogoErro(
          titulo: 'Confirmar Exclusão',
          mensagem: 'Você realmente deseja excluir esta movimentação?',
          textoBotao1: 'Cancelar',
          onBotao1Pressed: () {
            shouldDelete = false;
            Navigator.of(context).pop();
          },
          textoBotao2: 'Excluir',
          onBotao2Pressed: () {
            shouldDelete = true;
            Navigator.of(context).pop();
          },
        );
      },
    );

    return shouldDelete;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: Scaffold(
        backgroundColor: Color(0xFFf3f3f3),
        appBar: CustomAppBar(
          titleText: 'Histórico',
          customHeight: 70,
        ),
        drawer: CustomDrawer(),
        body: movimentacoes.isEmpty
            ? Center(child: Text('Nenhuma movimentação encontrada'))
            : ListView.builder(
          padding: EdgeInsets.only(top: 16, bottom: 30),
          itemCount: movimentacoes.length,
          itemBuilder: (context, index) {
            final mov = movimentacoes[index];
            return Dismissible(
              key: Key(mov['mov_sqlite'].toString()),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await _confirmDismiss(context, mov);
                }
                return false;
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  _deletarMovimentacao(mov['mov_sqlite']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Movimentação ${mov['mov_sqlite']} deletada')),
                  );
                }
              },
              background: Container(
                color: Theme.of(context).colorScheme.primary,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Movimentacao(
                id: mov['mov_sqlite'],
                data: DateTime.parse(mov['data']),
                origem: mov['origem'],
                destino: mov['destino'] ?? 'N/A',
                totalPecas: mov['total_pecas'],
                usuario: mov['usuario'],
                status: mov['status'],
              ),
            );
          },
        ),
        floatingActionButton: BotaoAdicionarMov(
          onPressed: () {
            Navigator.pushNamed(context, '/nova_mov');
          },
          heroTag: 'uniqueEncerrarButtonForNovaMov',  // Hero tag único para evitar conflitos
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
