import 'package:flutter/material.dart';

class BotaoEncerrar extends StatelessWidget {
  final VoidCallback onPressed;
  final Object? heroTag;

  BotaoEncerrar({required this.onPressed, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 5,
      heroTag: heroTag,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ), // Adiciona um formato arredondado ao botão
      child: Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      tooltip: 'Encerrar',
    );
  }
}
