import 'package:flutter/material.dart';

class BotaoEncerrar extends StatelessWidget {
  final VoidCallback onPressed;

  BotaoEncerrar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 7, 8, 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1), // Define a borda branca
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextButton(
          onPressed: () {
            onPressed();
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Encerrar', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Colors.white, size: 25),
            ],
          ),
        ),
      ),
    );
  }
}
