import 'package:AppEstoqueMP/modelos/movimentacao.dart';
import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/componentes/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/botao_adicionar_mov.dart';
import 'package:AppEstoqueMP/componentes/botao_rolar_topo.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:provider/provider.dart';

class HistMov extends StatefulWidget {
  @override
  _HistMovState createState() => _HistMovState();
}

class _HistMovState extends State<HistMov> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;
  bool _isInitialLoad = true;
  bool _isDeleting = false;
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: false);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showScrollToTopButton = _scrollController.offset > 200;
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _isInitialLoad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final movimentacaoProvider =
            Provider.of<ProvMovimentacao>(context, listen: false);
        await movimentacaoProvider.verificarERecarregarMovs();
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

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: Scaffold(
        appBar: CustomAppBar(titleText: 'Histórico do dia', customHeight: 70),
        drawer: CustomDrawer(),
        body: Consumer<ProvMovimentacao>(
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
                movimentacaoProvider.movsDoDia.sort((a, b) =>
                    a.status.compareTo(b.status)); // Ordenação por response
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
                    key: Key(mov.movServidor != 0
                        ? mov.movServidor.toString()
                        : 'sqlite_${mov.movSqlite}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        final teste = await _confirmDismiss(context, mov);
                        if (teste) {
                          setState(() {
                            _isDeleting = true; // Iniciar animação
                          });

                          final movimentacaoProvider =
                              Provider.of<ProvMovimentacao>(context,
                                  listen: false);
                          try {
                            final response = await movimentacaoProvider
                                .removerMovimentacao(mov);

                            setState(() {
                              _isDeleting =
                                  false; // Encerrar animação em caso de sucesso
                            });

                            if (response['status'] == 200 ||
                                response['status'] == 204) {
                              return true;
                            } else {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogo(
                                    titulo: 'Erro',
                                    mensagem: response['error'],
                                  );
                                },
                              );
                              return false;
                            }
                          } catch (e) {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialogo(
                                  titulo: 'Erro',
                                  mensagem: e.toString(),
                                );
                              },
                            );
                            setState(() {
                              _isDeleting =
                                  false; // Encerrar animação em caso de erro
                            });
                            return false;
                          }
                        }
                      }
                      return false;
                    },
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        setState(() {
                          movimentacaoProvider.movsDoDia.removeAt(index);
                        });
                      }
                    },
                    background: Container(
                      color: Theme.of(context).colorScheme.primary,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 13), // Espaço superior
                          Icon(Icons.delete,
                              color: Colors.white), // Ícone da lixeira no meio
                          if (!_isDeleting)
                            SizedBox(
                                height:
                                    12), // Espaço inferior equivalente à barra de carregamento
                          if (_isDeleting)
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 8.0), // Mantém a barra no fundo
                              child: Stack(
                                children: [
                                  Container(
                                    height: 4.0,
                                    color: Color(
                                        0xFF212529), // Cor do fundo da barra de progresso
                                  ),
                                  AnimatedBuilder(
                                    animation: controller,
                                    builder: (context, child) {
                                      final screenWidth =
                                          MediaQuery.of(context).size.width;
                                      final startOffset = -100.0;
                                      return Transform.translate(
                                        offset: Offset(
                                          startOffset +
                                              (controller.value *
                                                  (screenWidth + 100)),
                                          0,
                                        ),
                                        child: Container(
                                          width: 100,
                                          height: 4.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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
