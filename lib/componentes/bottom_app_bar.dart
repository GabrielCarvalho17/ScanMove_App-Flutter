import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final Widget botaoVoltar;
  final Widget botaoFinalizar;
  final int contadorPecas;

  CustomBottomAppBar({
    required this.botaoVoltar,
    required this.botaoFinalizar,
    required this.contadorPecas,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).primaryColor,
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: botaoVoltar,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: botaoFinalizar,
                ),
              ],
            ),
            Positioned(
              bottom: -5,
              child: Text(
                '$contadorPecas',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
