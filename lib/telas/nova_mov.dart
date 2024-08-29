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

class NovaMov extends StatefulWidget {
  final int? id;

  NovaMov({this.id});

  @override
  _NovaMovState createState() => _NovaMovState();
}

class _NovaMovState extends State<NovaMov> {
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;
  bool _isInitialized = false;
  late ProvMovimentacao movimentacaoProvider;
  bool statusFinalizada = false;

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

  Future<void> _mostrarDialogoExclusao(BuildContext context, int index) async {
    final peca = movimentacaoProvider.movimentacaoAtual!.pecas[index];
    final idPeca = peca.peca.toString();

    final shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogo(
          titulo: 'Confirmar Exclusão',
          mensagem: 'Você realmente deseja excluir esta peça?',
          textoBotao1: 'Cancelar',
          onBotao1Pressed: () {
            Navigator.of(context).pop(false);
          },
          textoBotao2: 'Excluir',
          onBotao2Pressed: () {
            Navigator.of(context).pop(true);
          },
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        movimentacaoProvider.removerPeca(idPeca);
        print(movimentacaoProvider.toString());
      });
    }
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
                            await _mostrarDialogoExclusao(context, index);
                            return false;
                          }
                          return false;
                        },
                        background: Container(
                          color: Theme.of(context).colorScheme.primary,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                        ),
                        child: Peca(
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
          floatingActionButton: statusFinalizada
              ? null
              : Stack(
                  children: [
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
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
