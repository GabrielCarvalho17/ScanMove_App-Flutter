import 'package:flutter/material.dart';

class BotaoAdicionarMov extends StatelessWidget {
  final Function()? onPressed;
  final Object? heroTag;  // Adicionei o parâmetro heroTag

  BotaoAdicionarMov({required this.onPressed, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent, // Transparent to show the container's color
        elevation: 5,
        heroTag: heroTag,  // Utiliza a tag hero única
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
