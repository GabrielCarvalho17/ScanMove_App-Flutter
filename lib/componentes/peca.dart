import 'package:flutter/material.dart';

class Peca extends StatelessWidget {
  final String peca;
  final String partida;
  final String material;
  final String descMaterial;
  final String cor;
  final String descCor;
  final String unidade;
  final double qtde;
  final List<Map<String, dynamic>> pecas;
  final State parentState;

  const Peca({
    Key? key,
    required this.peca,
    required this.partida,
    required this.material,
    required this.descMaterial,
    required this.cor,
    required this.descCor,
    required this.unidade,
    required this.qtde,
    required this.pecas,
    required this.parentState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$peca - $partida',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Transform.translate(
                    offset: Offset(4, 0),
                    child: GestureDetector(
                      onTap: () {
                        pecas.removeWhere((element) => element['peca'] == peca);
                        parentState.setState(() {}); // Atualiza a tela
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('$material - $descMaterial'),
              SizedBox(height: 10),
              Text('$cor - $descCor'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Unidade: $unidade'),
                  Text('Qtde: $qtde'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
