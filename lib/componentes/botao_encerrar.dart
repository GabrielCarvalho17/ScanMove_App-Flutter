import 'package:flutter/material.dart';

class BotaoEncerrar extends StatelessWidget {
  final VoidCallback onPressed;

  BotaoEncerrar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            onPressed();
          },
          child: CircleAvatar(
            radius: 20, // Ajuste o tamanho do botão circular
            backgroundColor: Color(0xFF1A7F64), // Cor de fundo do botão
            child: Icon(
              Icons.arrow_forward,
              color: Colors.white, // Cor do ícone
              size: 24, // Ajuste o tamanho do ícone
            ),
          ),
        ),
        SizedBox(height: 4), // Ajuste o espaçamento entre o ícone e o texto
        Text(
          'Encerrar',
          style: TextStyle(color: Colors.white, fontSize: 14), // Ajuste o tamanho do texto
        ),
      ],
    );
  }
}
