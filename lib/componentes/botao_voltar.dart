import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/origem_destino.dart';

class BotaoVoltar extends StatelessWidget {
  final VoidCallback onPressed;

  BotaoVoltar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 7, 15, 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1), // Define a borda branca
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextButton.icon(
          onPressed: () {
            // Limpa o valor de origem no provedor
            Provider.of<ProvOrigemDestino>(context, listen: false).setOrigem('');
            onPressed();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 25),
          label: Text('Retornar', style: TextStyle(color: Colors.white, fontSize: 16)),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
