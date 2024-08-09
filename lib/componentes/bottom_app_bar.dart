import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final Widget botaoVoltar;
  final Widget botaoFinalizar;
  final int contadorPecas;
  final bool exibirTextoTotal; // Novo parâmetro

  CustomBottomAppBar({
    required this.botaoVoltar,
    required this.botaoFinalizar,
    required this.contadorPecas,
    this.exibirTextoTotal = false, // Valor padrão é falso
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.0, // Defina a altura desejada aqui
      child: BottomAppBar(
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
                bottom: 0, // Ajuste a posição do contador conforme necessário
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (exibirTextoTotal)
                      Text(
                        'Total',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    SizedBox(height: 8),
                    Text(
                      '$contadorPecas',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
