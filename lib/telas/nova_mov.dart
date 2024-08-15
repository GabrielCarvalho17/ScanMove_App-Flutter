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
import 'package:AppEstoqueMP/servicos/sqlite.dart';
import 'package:provider/provider.dart';

class NovaMov extends StatefulWidget {
  final int? id;

  NovaMov({this.id});

  @override
  _NovaMovState createState() => _NovaMovState();
}

class _NovaMovState extends State<NovaMov> {
  final SQLite sqlite = SQLite();
  List<Map<String, dynamic>> _pecas = [];
  bool isLoading = true;
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;
  bool statusFinalizada = false;
  late MovimentacaoProvider movimentacaoProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        _onScroll();
      });

    // Atraso inicial de 5 milissegundos
    Future.delayed(Duration(milliseconds: 5), () {
      setState(() {
        _isInitialized = true;
      });
    });

    if (widget.id != null) {
      _carregarMovimentacao(widget.id!);
    } else {
      setState(() {
        isLoading = false;
      });
    }
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
    movimentacaoProvider =
        Provider.of<MovimentacaoProvider>(context, listen: false);

    // Verifica se a movimentação está finalizada
    statusFinalizada = movimentacaoProvider.statusMovimentacao == 'Finalizada';

  }

  Future<void> _carregarMovimentacao(int movServidor) async {
    try {
      final dados = await sqlite.obterMovimentacaoComPecas(movServidor);
      final movimentacao = dados['movimentacao'];
      final pecas = dados['pecas'];

      // Atualiza o provedor com os valores carregados
      movimentacaoProvider.setMovServidor(movimentacao['mov_servidor']);
      movimentacaoProvider.setOrigem(movimentacao['origem']);
      movimentacaoProvider.setDestino(movimentacao['destino']);
      movimentacaoProvider.setDataInicio(movimentacao['data_inicio']);
      movimentacaoProvider.setDataModificacao(movimentacao['data_modificacao']);
      movimentacaoProvider.setFilialOrigem(movimentacao['filial_origem']);
      movimentacaoProvider.setFilialDestino(movimentacao['filial_destino']);
      movimentacaoProvider.setUsuario(movimentacao['usuario']);
      movimentacaoProvider.setTotalPecas(pecas.length);
      movimentacaoProvider.setStatusMovimentacao(movimentacao['status']);

      if (pecas.isNotEmpty) {
        final primeiraLocalizacao = pecas.first['localizacao'];
        movimentacaoProvider.setLocalizacaoPeca(primeiraLocalizacao);
      }

      movimentacaoProvider.setpecas(List<Map<String, dynamic>>.from(pecas));

      print(movimentacaoProvider.toString());
      setState(() {
        _pecas = List<Map<String, dynamic>>.from(pecas);
        isLoading = false;
      });

      // Revalida o status finalizado após carregar os dados
      statusFinalizada =
          movimentacaoProvider.statusMovimentacao == 'Finalizada';
    } catch (e) {
      print('Erro ao carregar movimentação: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _mostrarDialogoExclusao(BuildContext context, int index) {
    return showDialog(
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
    ).then((shouldDelete) {
      if (shouldDelete) {
        setState(() {
          _pecas.removeAt(index);
          // Atualiza o total de peças no provedor
          movimentacaoProvider.setTotalPecas(_pecas.length);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Color(0xFFf3f3f3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: Scaffold(
        backgroundColor: Color(0xFFf3f3f3),
        appBar: CustomAppBar(
          titleText: widget.id != null ? '0000${widget.id}' : 'Movimentar',
          bottom: OrigemDestino(),
          customLeading: BotaoVoltar(),
        ),
        drawer: CustomDrawer(),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 16.0, bottom: 80),
                      itemCount: _pecas.length,
                      itemBuilder: (context, index) {
                        final item = _pecas[index];
                        return Dismissible(
                          key: Key(item['peca'].toString()),
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
                            peca: item['peca'].toString(),
                            partida: item['partida'].toString(),
                            material: item['material'].toString(),
                            descMaterial: item['desc_material'].toString(),
                            cor: item['cor_material'].toString(),
                            descCor: item['desc_cor_material'].toString(),
                            unidade: item['unidade'].toString(),
                            qtde: item['quantidade'] as double,
                          ),
                        );
                      },
                    ),
                  ),
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
    );
  }
}
