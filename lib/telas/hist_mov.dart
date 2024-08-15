import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/componentes/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/botao_adicionar_mov.dart';
import 'package:AppEstoqueMP/componentes/botao_sincronizar.dart';
import 'package:AppEstoqueMP/componentes/botao_rolar_topo.dart';
import 'package:AppEstoqueMP/servicos/movimentacao.dart';
import 'package:AppEstoqueMP/modelos/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:provider/provider.dart';

class HistMov extends StatefulWidget {
  @override
  _HistMovState createState() => _HistMovState();
}

class _HistMovState extends State<HistMov> {
  List<MovimentacaoModel> movimentacoes = [];
  final ServMovimentacao servMovimentacao = ServMovimentacao();
  bool isLoading = true;
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showScrollToTopButton = _scrollController.offset > 200;
        });
      });

    _carregarMovimentacoes();
  }

  Future<void> _carregarMovimentacoes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final movimentacoesExistentes =
          await servMovimentacao.getMovimentacoesExistentes();

      if (movimentacoesExistentes.isEmpty) {
        movimentacoes = await servMovimentacao.obterMovimentacoesDoServidor();
      } else {
        movimentacoes = movimentacoesExistentes;
      }
    } catch (e) {
      print('Erro ao carregar movimentações: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _confirmDismiss(
      BuildContext context, MovimentacaoModel mov) async {
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

  Future<bool> _deletarMovimentacao(int movServidor) async {
    bool retorno = await servMovimentacao.deletarMovimentoLocal(movServidor);
    if (retorno) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: Scaffold(
        appBar: CustomAppBar(titleText: 'Histórico', customHeight: 70),
        drawer: CustomDrawer(),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : movimentacoes.isEmpty
                ? Center(child: Text('Nenhuma movimentação encontrada'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: movimentacoes.length,
                    itemBuilder: (context, index) {
                      final mov = movimentacoes[index];
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
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              setState(() {
                                movimentacoes.removeAt(index);
                              });

                              _deletarMovimentacao(mov.movServidor);
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
                    }),
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
              left: MediaQuery.of(context).size.width / 2 - 28,
              bottom: 0,
              child: BotaoSincronizar(
                onPressed: () {
                  print('Sincronizar!');
                },
                heroTag: 'uniqueSyncButton',
              ),
            ),
            Positioned(
              right: 20,
              bottom: 0,
              child: BotaoAdicionarMov(
                onPressed: () async {
                  Navigator.pushNamed(context, '/nova_mov');
                  final movimentacaoProvider =
                      Provider.of<MovimentacaoProvider>(context, listen: false);
                  await movimentacaoProvider.limparEstadoAnterior();
                  print(movimentacaoProvider.toString());
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
