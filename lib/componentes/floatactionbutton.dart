import 'package:flutter/material.dart';

class BotaoFlutuante extends StatelessWidget {
  final Function()? onPressed;

  BotaoFlutuante({required this.onPressed});

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
