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
    int movimentacaoId = movimentacoes[index]['mov_sqlite'];
    int? movServidor = movimentacoes[index]['mov_servidor'];

    setState(() {
      movimentacoes.removeAt(index);
    });

    try {
      // Exclua os itens associados à movimentação
      await dbHelper.deletarEstoqueMatMovItensPorMovimentacao(movimentacaoId, movServidor);

      // Exclua a movimentação
      await dbHelper.deletarEstoqueMatMov(movimentacaoId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movimentação removida')),
      );
    } catch (e) {
      // Adiciona a movimentação de volta em caso de erro
      setState(() {
        movimentacoes.insert(index, {
          'mov_sqlite': movimentacaoId,
          'mov_servidor': movServidor,
          'data': movimentacoes[index]['data'],
          'usuario': movimentacoes[index]['usuario'],
          'origem': movimentacoes[index]['origem'],
          'destino': movimentacoes[index]['destino'],
          'filial_origem': movimentacoes[index]['filial_origem'],
          'filial_destino': movimentacoes[index]['filial_destino'],
          'total_pecas': movimentacoes[index]['total_pecas'],
          'status': movimentacoes[index]['status'],
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover movimentação')),
      );
    }
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
            key: Key(mov['mov_sqlite'].toString()),
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
                  arguments: mov['mov_sqlite'],
                );
              },
              child: Movimentacao(
                id: mov['mov_sqlite'],
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
