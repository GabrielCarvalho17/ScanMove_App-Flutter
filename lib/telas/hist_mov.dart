import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/floatactionbutton.dart';
import 'package:AppEstoqueMP/componentes/movimentacao.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class HistMov extends StatefulWidget {
  @override
  _HistMovState createState() => _HistMovState();
}

class _HistMovState extends State<HistMov> {
  bool isFabVisible = true;
  List<Map<String, dynamic>> movimentacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarMovimentacoes();
  }

  Future<void> _carregarMovimentacoes() async {
    final SQLite dbHelper = SQLite();
    final movs = await dbHelper.obterEstoqueMatMov();
    setState(() {
      movimentacoes = movs;
    });
  }

  Future<void> _removerMovimentacao(int index) async {
    final SQLite dbHelper = SQLite();
    await dbHelper.deletarEstoqueMatMov(movimentacoes[index]['id']);

    setState(() {
      movimentacoes.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Movimentação removida')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf3f3f3),
      appBar: CustomAppBar(
        titleText: 'Histórico',
        customHeight: 70,
        onSearchOpen: () {
          setState(() {
            isFabVisible = false;
          });
        },
        onSearchClose: () {
          setState(() {
            isFabVisible = true;
          });
        },
      ),
      drawer: CustomDrawer(),
      body: movimentacoes.isEmpty
          ? Center(child: Text('Nenhuma movimentação encontrada'))
          : ListView.builder(
        padding: const EdgeInsets.only(top: 16.0, bottom: 30),
        itemCount: movimentacoes.length,
        itemBuilder: (context, index) {
          final mov = movimentacoes[index];
          return Dismissible(
            key: Key(mov['id'].toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _removerMovimentacao(index);
            },
            background: Container(
              color: Theme.of(context).primaryColor,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/nova_mov',
                  arguments: mov['id'],
                );
              },
              child: Movimentacao(
                id: mov['id'],
                data: DateTime.parse(mov['data']),
                origem: mov['origem'],
                destino: mov['destino'],
                totalPecas: mov['total_pecas'],
                usuario: mov['usuario'],
                status: mov['status'],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: isFabVisible,
        child: BotaoFlutuante(
          onPressed: () {
            Navigator.pushNamed(context, '/nova_mov');
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
