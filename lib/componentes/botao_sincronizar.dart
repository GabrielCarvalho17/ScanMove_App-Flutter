import 'package:flutter/material.dart';

class BotaoSincronizar extends StatelessWidget {
  final Function()? onPressed;
  final Object? heroTag;

  BotaoSincronizar({required this.onPressed, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      heroTag: heroTag,
      child: Icon(
        Icons.sync,
        color: Colors.white,
      ),
    );
  }
}
