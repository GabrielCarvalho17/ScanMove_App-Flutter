import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/origem_destino.dart';
import 'package:AppEstoqueMP/componentes/bottom_app_bar.dart';
import 'package:AppEstoqueMP/componentes/peca.dart';
import 'package:AppEstoqueMP/componentes/botao_adicionar_peca.dart';
import 'package:AppEstoqueMP/componentes/botao_retornar.dart';
import 'package:AppEstoqueMP/componentes/botao_encerrar.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';

class NovaMov extends StatefulWidget {
  @override
  _NovaMovState createState() => _NovaMovState();
}

class _NovaMovState extends State<NovaMov> {
  List<Map<String, dynamic>> pecas = [];
  bool isFabVisible = true;

  void adicionarPeca(Map<String, dynamic> peca) {
    if (pecas.any((element) => element['peca'] == peca['peca'])) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Atenção',
            mensagem: 'Já existe uma peça com este código.',
          );
        },
      );
    } else {
      setState(() {
        pecas.add(peca);
      });
    }
  }

  void removerPeca(String pecaCodigo) {
    setState(() {
      pecas.removeWhere((peca) => peca['peca'] == pecaCodigo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf3f3f3),
      appBar: CustomAppBar(
        titleText: 'Movimentar',
        bottom: FormOrigemDestino(),
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
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 16.0, bottom: 30), // Adiciona padding ao redor do ListView
        itemCount: pecas.length,
        itemBuilder: (context, index) {
          final peca = pecas[index];
          return Peca(
            peca: peca['peca'],
            partida: peca['partida'],
            material: peca['material'],
            descMaterial: peca['descMaterial'],
            cor: peca['cor'],
            descCor: peca['descCor'],
            unidade: peca['unidade'],
            qtde: peca['qtde'],
            pecas: pecas,
            parentState: this,
          );
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(
        botaoVoltar: BotaoRetornar(
          pecas: pecas,  // Passa a lista de peças para o BotaoRetornar
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/hist_mov');
          },
        ),
        botaoFinalizar: BotaoEncerrar(
          onPressed: () {
            print('Encerrar!');
          },
        ),
        contadorPecas: pecas.length, // Passa o número de peças para o BottomAppBar
      ),
      floatingActionButton: Visibility(
        visible: isFabVisible,
        child: BotaoAdicionarPeca(
          onPecaAdicionada: (peca) {
            adicionarPeca(peca);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
