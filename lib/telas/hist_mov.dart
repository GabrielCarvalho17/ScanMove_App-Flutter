import 'package:AppEstoqueMP/modelos/movimentacao.dart';
import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/componentes/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/botao_adicionar_mov.dart';
import 'package:AppEstoqueMP/componentes/botao_sincronizar.dart';
import 'package:AppEstoqueMP/componentes/botao_rolar_topo.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:provider/provider.dart';

class HistMov extends StatefulWidget {
  @override
  _HistMovState createState() => _HistMovState();
}

class _HistMovState extends State<HistMov> {
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showScrollToTopButton = _scrollController.offset > 200;
        });
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _isInitialLoad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final movimentacaoProvider = Provider.of<MovimentacaoProvider>(context, listen: false);
        await movimentacaoProvider.verificarERecarregarMovs();
      });
    }
  }

  Future<bool> _confirmDismiss(BuildContext context, MovimentacaoModel mov) async {
    if (mov.status == 'Finalizada') {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogo(
            titulo: 'Ação Impossível',
            mensagem: 'Não é possível excluir uma movimentação finalizada.',
          );
        },
      );
      return false;
    }

    bool shouldDelete = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogo(
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
        appBar: CustomAppBar(titleText: 'Histórico do dia', customHeight: 70),
        drawer: CustomDrawer(),
        body: Consumer<MovimentacaoProvider>(
          builder: (context, movimentacaoProvider, child) {
            if (movimentacaoProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (movimentacaoProvider.movsDoDia.isEmpty) {
              return Center(child: Text('Nenhuma movimentação encontrada'));
            }

            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 16, bottom: 80),
              itemCount: movimentacaoProvider.movsDoDia.length,
              itemBuilder: (context, index) {
                final mov = movimentacaoProvider.movsDoDia[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/nova_mov',
                      arguments: {
                        'id': mov.movServidor,
                      },
                    );
                  },
                  child: Dismissible(
                    key: Key(mov.movServidor.toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        return await _confirmDismiss(context, mov);
                      }
                      return false;
                    },
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        await movimentacaoProvider.removerMovimentacao(mov.movServidor);
                      }
                    },
                    background: Container(
                      color: Theme.of(context).colorScheme.primary,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: MovimentacaoCard(
                      id: mov.movServidor,
                      data: DateTime.parse(mov.dataInicio),
                      origem: mov.origem,
                      destino: mov.destino,
                      totalPecas: mov.totalPecas,
                      usuario: mov.usuario,
                      status: mov.status,
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Stack(
          children: [
            if (_showScrollToTopButton)
              Positioned(
                left: 20,
                bottom: 0,
                child: BotaoRolarTopo(
                  onPressed: () {
                    _scrollController.animateTo(0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  heroTag: 'uniqueScrollTopButton',
                ),
              ),
            Positioned(
              right: 20,
              bottom: 0,
              child: BotaoAdicionarMov(
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
