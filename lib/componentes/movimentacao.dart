import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/telas/detalhes_mov.dart';

class Movimentacao extends StatelessWidget {
  final int id;
  final DateTime data;
  final String origem;
  final String destino;
  final int totalPecas;
  final String usuario;
  final String status;

  const Movimentacao({
    Key? key,
    required this.id,
    required this.data,
    required this.origem,
    required this.destino,
    required this.totalPecas,
    required this.usuario,
    required this.status,
  }) : super(key: key);

  void _navegarParaDetalhes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetalhesMov(id: id.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 6),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () => _navegarParaDetalhes(context),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.swap_horiz,
                          size: 25.0,
                          color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 10),
                      Text(
                        '$id',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ]),
                    Text(
                      '${data.toLocal().toString().split(' ')[0]} ${data.hour}:${data.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Origem: $origem', style: TextStyle(fontSize: 15)),
                    Text(
                      'Total: $totalPecas',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text('Destino: $destino', style: TextStyle(fontSize: 15)),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Autor: $usuario',
                      style: TextStyle(fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFb9bdbf),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
