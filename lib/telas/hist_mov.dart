import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/componentes/drawer.dart';
import 'package:AppEstoqueMP/componentes/app_bar.dart';
import 'package:AppEstoqueMP/componentes/floatactionbutton.dart';

class HistMov extends StatefulWidget {
  @override
  _HistMovState createState() => _HistMovState();
}

class _HistMovState extends State<HistMov> {
  bool isFabVisible = true;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        // Adicione o conteúdo do corpo aqui
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