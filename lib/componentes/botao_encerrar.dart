import 'package:flutter/material.dart';

class BotaoEncerrar extends StatelessWidget {
  final VoidCallback onPressed;
  final Object? heroTag;  // Adiciona o parâmetro heroTag

  BotaoEncerrar({required this.onPressed, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent, // Transparente para mostrar a cor do Container
        elevation: 5,
        heroTag: heroTag,  // Utiliza a tag hero única
        child: Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
        tooltip: 'Encerrar',
      ),
    );
  }
}
