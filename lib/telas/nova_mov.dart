import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/origem_destino.dart';
import 'package:AppEstoqueMP/componentes/peca.dart';
import 'package:AppEstoqueMP/componentes/botao_adicionar_peca.dart';
import 'package:AppEstoqueMP/componentes/botao_encerrar.dart';
import 'package:AppEstoqueMP/provedores/origem_destino.dart';
import 'package:AppEstoqueMP/componentes/botao_voltar.dart';
import 'package:AppEstoqueMP/provedores/peca.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class NovaMov extends StatefulWidget {
  final int? id;
  final String? status;

  NovaMov({this.id, this.status});

  @override
  _NovaMovState createState() => _NovaMovState();
}

class _NovaMovState extends State<NovaMov> {
  List<Map<String, dynamic>> pecas = [];
  bool isReadOnly = false;
  final SQLite _dbHelper = SQLite();
  Map<String, String>? dadosMovimentacao;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _carregarMovimentacao(widget.id!);
    }
    if (widget.status == 'Finalizada') {
      setState(() {
        isReadOnly = true;
      });
    }
  }

  Future<void> _carregarMovimentacao(int id) async {
    final provOrigemDestino = Provider.of<ProvOrigemDestino>(context, listen: false);
    final provPeca = Provider.of<ProvPeca>(context, listen: false);
    final movimentacao = await _dbHelper.obterMovimentoPorId(id);
    final itens = await _dbHelper.obterItensPorMovimento(id, movimentacao['mov_servidor']);

    if (movimentacao.isNotEmpty) {
      dadosMovimentacao = {
        'origem': movimentacao['origem'],
        'filial_origem': movimentacao['filial_origem'],
        'destino': movimentacao['destino'] ?? '',
        'filial_destino': movimentacao['filial_destino'] ?? '',
      };

      provOrigemDestino.setOrigem(movimentacao['origem'], filial: movimentacao['filial_origem']);
      provOrigemDestino.setDestino(movimentacao['destino'], filial: movimentacao['filial_destino']);

      if (itens.isNotEmpty) {
        final ultimaPeca = itens.last;
        provPeca.setUltimaPeca(ultimaPeca['localizacao'], ultimaPeca['filial']);
      } else {
        provPeca.limpar(); // Limpa caso não haja itens
      }
    }

    setState(() {
      pecas = itens.map((item) => {
        'peca': item['peca'],
        'partida': item['partida'],
        'material': item['material'],
        'descMaterial': item['desc_material'],
        'cor': item['cor_material'],
        'descCor': item['desc_cor_material'],
        'unidade': item['unidade'],
        'qtde': (item['quantidade'] is int) ? item['quantidade'].toDouble() : item['quantidade'],
        'filial': item['filial'],
        'localizacao': item['localizacao'],
      }).toList();
    });
  }

  void adicionarPeca(Map<String, dynamic> peca) {
    if (pecas.any((element) => element['peca'] == peca['peca'])) {
      showDialog(
        context: context,
        builder: (context) => DialogoErro(
          titulo: 'Atenção',
          mensagem: 'Já existe uma peça com este código.',
        ),
      );
    } else {
      setState(() {
        pecas.add(peca);
      });
      Provider.of<ProvPeca>(context, listen: false).setUltimaPeca(peca['localizacao'], peca['filial']);
    }
  }

  void removerPeca(int index) {
    setState(() {
      pecas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: Scaffold(
        backgroundColor: Color(0xFFf3f3f3),
        appBar: CustomAppBar(
          titleText: 'Movimentar',
          bottom: FormOrigemDestino(dados: dadosMovimentacao, isReadOnly: isReadOnly),
          customLeading: BotaoVoltar(
            pecas: pecas,
            status: widget.status,
            movimentacaoId: widget.id,
          ),
        ),
        drawer: CustomDrawer(),
        body: ListView.builder(
          padding: const EdgeInsets.only(top: 16.0, bottom: 30),
          itemCount: pecas.length,
          itemBuilder: (context, index) {
            final peca = pecas[index];
            return Dismissible(
              key: Key(peca['peca']),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => removerPeca(index),
              background: Container(
                color: Theme.of(context).primaryColor,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Peca(
                peca: peca['peca'],
                partida: peca['partida'],
                material: peca['material'],
                descMaterial: peca['descMaterial'] ?? '',
                cor: peca['cor'] ?? '',
                descCor: peca['descCor'] ?? '',
                unidade: peca['unidade'] ?? '',
                qtde: peca['qtde'] ?? 0.0,
              ),
            );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 32, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 40), // Espaço vazio para manter o botão centralizado
              BotaoAdicionarPeca(
                onPecaAdicionada: (peca) {
                  adicionarPeca(peca);
                },
                heroTag: 'uniqueAddPecaButtonForNovaMov',  // Hero tag único para evitar conflitos
              ),
              BotaoEncerrar(
                onPressed: () {
                  print('Encerrar!');
                },
                heroTag: 'uniqueEncerrarButtonForNovaMov',  // Hero tag único para evitar conflitos
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
