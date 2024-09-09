import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/componentes/peca.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/botao_adicionar_peca.dart';
import 'package:AppEstoqueMP/componentes/botao_finalizar.dart';
import 'package:AppEstoqueMP/componentes/botao_rolar_topo.dart';
import 'package:AppEstoqueMP/componentes/botao_voltar.dart';
import 'package:AppEstoqueMP/componentes/origem_destino.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:provider/provider.dart';

import '../modelos/movimentacao.dart';
import '../modelos/peca.dart';

class NovaMov extends StatefulWidget {
  final int? id;

  NovaMov({this.id});

  @override
  _NovaMovState createState() => _NovaMovState();
}

class _NovaMovState extends State<NovaMov> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;
  bool _isInitialized = false;
  late ProvMovimentacao movimentacaoProvider;
  bool statusFinalizada = false;
  bool _isDeleting = false;
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        _onScroll();
      });

    Future.delayed(Duration(milliseconds: 5), () {
      setState(() {
        _isInitialized = true;
      });
    });

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

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showScrollToTopButton) {
      setState(() {
        _showScrollToTopButton = true;
      });
    } else if (_scrollController.offset <= 200 && _showScrollToTopButton) {
      setState(() {
        _showScrollToTopButton = false;
      });
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      movimentacaoProvider =
          Provider.of<ProvMovimentacao>(context, listen: false);

      if (widget.id != null) {
        final movimentacao =
            movimentacaoProvider.obterMovimentacaoPorId(widget.id!);
        if (movimentacao != null) {
          movimentacaoProvider.setMovimentacaoAtual(movimentacao);
          statusFinalizada = movimentacao.status == 'Finalizada';
        }
      }

      _isInitialized = true;
    });
  }

  Future<bool> _confirmDismiss(BuildContext context, PecaModel peca,
      MovimentacaoModel movimentacao) async {
    // Verifica se a movimentação está finalizada, então não pode excluir a peça
    if (movimentacao.status == 'Finalizada') {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogo(
            titulo: 'Ação Impossível',
            mensagem: 'A movimentação já está finalizada.',
          );
        },
      );
      return false; // Não permitir exclusão
    }

    bool shouldDelete = false;

    // Exibir diálogo de confirmação de exclusão da peça
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogo(
          titulo: 'Confirmar Exclusão',
          mensagem: 'Você realmente deseja excluir esta peça?',
          textoBotao1: 'Cancelar',
          onBotao1Pressed: () {
            shouldDelete = false; // Cancelar exclusão
            Navigator.of(context).pop();
          },
          textoBotao2: 'Excluir',
          onBotao2Pressed: () {
            shouldDelete = true; // Confirmar exclusão
            Navigator.of(context).pop();
          },
        );
      },
    );

    // Retorna se o usuário confirmou ou cancelou a exclusão
    return shouldDelete;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return PopScope(
        onPopInvoked: (didPop) async {
          // Substitui a funcionalidade do onWillPop
          final movimentacaoProvider =
              Provider.of<ProvMovimentacao>(context, listen: false);
          await movimentacaoProvider.verificarERecarregarMovs();
          print(movimentacaoProvider.toString());

          return; // Retorna void para cumprir com a assinatura esperada
        },
        child: Scaffold(
          backgroundColor: Color(0xFFf3f3f3),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: PopScope(
        onPopInvoked: (didPop) async {
          // Substitui a funcionalidade do onWillPop
          final movimentacaoProvider =
              Provider.of<ProvMovimentacao>(context, listen: false);
          await movimentacaoProvider.verificarERecarregarMovs();
          print(movimentacaoProvider.toString());

          return; // Retorna void para cumprir com a assinatura esperada
        },
        child: Scaffold(
          backgroundColor: Color(0xFFf3f3f3),
          appBar: CustomAppBar(
            titleText: widget.id != null ? '0000${widget.id}' : 'Movimentar',
            bottom: OrigemDestino(),
            customLeading: BotaoVoltar(),
          ),
          drawer: CustomDrawer(),
          body: Column(
            children: [
              Expanded(child: Consumer<ProvMovimentacao>(
                  builder: (context, movimentacaoProvider, child) {
                if (movimentacaoProvider.movimentacaoAtual == null) {
                  return Container();
                } else {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16.0, bottom: 80),
                    itemCount:
                        movimentacaoProvider.movimentacaoAtual!.pecas.length,
                    itemBuilder: (context, index) {
                      final item =
                          movimentacaoProvider.movimentacaoAtual!.pecas[index];
                      return Dismissible(
                        key: Key(item.peca.toString()),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            final confirmacao = await _confirmDismiss(context,
                                item, movimentacaoProvider.movimentacaoAtual!);

                            if (confirmacao) {
                              setState(() {
                                _isDeleting =
                                    true; // Iniciar animação de exclusão
                              });

                              final movimentacaoProvider =
                                  Provider.of<ProvMovimentacao>(context,
                                      listen: false);

                              try {
                                // Chama o método para remover a peça
                                final response = await movimentacaoProvider
                                    .removerPeca(item.peca);

                                setState(() {
                                  _isDeleting =
                                      false; // Para a animação após a conclusão
                                });

                                // Verifica a resposta do servidor
                                if (response['status'] == 200 ||
                                    response['status'] == 204) {
                                  return true; // Permite a remoção visual do item
                                } else {
                                  // Exibe um diálogo em caso de erro na remoção
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
                                // Trata erros durante a exclusão
                                setState(() {
                                  _isDeleting =
                                      false; // Para a animação em caso de erro
                                });

                                // Exibe um diálogo de erro
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogo(
                                      titulo: 'Erro',
                                      mensagem: e.toString(),
                                    );
                                  },
                                );
                                return false;
                              }
                            }
                            return false;
                          }
                          return false;
                        },
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            // Remove a peça da lista local após a confirmação de sucesso
                            setState(() {
                              movimentacaoProvider.movimentacaoAtual!.pecas
                                  .removeAt(index);
                            });
                          }
                        },
                        background: Container(
                          color: Theme.of(context).colorScheme.primary,
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(bottom: 9, top: 4),
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(height: 13), // Espaço superior
                              Icon(Icons.delete,
                                  color:
                                      Colors.white), // Ícone da lixeira no meio
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
                        child: PecaCard(
                          peca: item.peca,
                          partida: item.partida ?? '',
                          material: item.material,
                          descMaterial: item.descMaterial,
                          cor: item.corMaterial,
                          descCor: item.descCorMaterial,
                          unidade: item.unidade,
                          qtde: item.quantidade,
                        ),
                      );
                    },
                  );
                }
              })),
            ],
          ),
          floatingActionButton: Stack(children: [
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
                  heroTag: 'uniqueScrollTopButtonForNovaMov',
                ),
              ),
            if (!statusFinalizada) ...[
              Positioned(
                left: MediaQuery.of(context).size.width / 2 - 28,
                bottom: 0,
                child: BotaoAdicionarPeca(
                  heroTag: 'uniqueAddPecaButtonForNovaMov',
                ),
              ),
              Positioned(
                right: 20,
                bottom: 0,
                child: BotaoFinalizar(
                  heroTag: 'uniqueEncerrarButtonForNovaMov',
                ),
              ),
            ],
          ]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
