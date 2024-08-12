import 'package:flutter/material.dart';

class BotaoRolarTopo extends StatelessWidget {
  final Function()? onPressed;
  final Object? heroTag;

  BotaoRolarTopo({required this.onPressed, this.heroTag});

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
        Icons.arrow_upward,
        color: Colors.white,
      ),
    );
  }
}
