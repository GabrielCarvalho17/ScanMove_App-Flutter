import 'package:flutter/material.dart';

class BotaoAdicionarMov extends StatelessWidget {
  final Function()? onPressed;
  final Object? heroTag;  // Adicionei o parâmetro heroTag

  BotaoAdicionarMov({required this.onPressed, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).primaryColor, // Transparent to show the container's color
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      heroTag: heroTag,  // Utiliza a tag hero única
      child: Center(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
