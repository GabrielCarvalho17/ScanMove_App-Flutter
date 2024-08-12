import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:AppEstoqueMP/componentes/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/botao_adicionar_mov.dart';
import 'package:AppEstoqueMP/componentes/botao_sincronizar.dart';
import 'package:AppEstoqueMP/componentes/botao_rolar_topo.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';  // Importar o dialogo
import 'package:AppEstoqueMP/provedores/peca.dart';

class HistMov extends StatefulWidget {
  @override
  _HistMovState createState() => _HistMovState();
}

class _HistMovState extends State<HistMov> {
  List<Map<String, dynamic>> movimentacoes = [];
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showScrollToTopButton = _scrollController.offset > 200; // Ajuste o valor conforme necessário
        });
      });
    _carregarMovimentacoes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          controller: _scrollController,
          padding: EdgeInsets.only(top: 16, bottom: 80),
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
        floatingActionButton: Stack(
          children: [
            // Botão para rolar para o topo (visível apenas quando necessário)
            if (_showScrollToTopButton)
              Positioned(
                left: 20,
                bottom: 0,
                child: BotaoRolarTopo(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  heroTag: 'uniqueScrollTopButton',
                ),
              ),
            // Botão de sincronizar (visível no centro)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 28,
              bottom: 0,
              child: BotaoSincronizar(
                onPressed: () {
                  // Implementar a lógica de sincronização aqui
                  print('Sincronizar!');
                },
                heroTag: 'uniqueSyncButton',
              ),
            ),
            // Botão de adicionar movimentação (visível sempre à direita)
            Positioned(
              right: 20,
              bottom: 0,
              child: BotaoAdicionarMov(
                onPressed: () {
                  // Zerar o contador de peças antes de navegar para a tela de nova movimentação
                  Provider.of<ProvPeca>(context, listen: false).inicializarContadorPeca(0);

                  Navigator.pushNamed(context, '/nova_mov');
                },
                heroTag: 'uniqueAddPecaButtonForNovaMov',
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
