import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovimentacaoCard extends StatelessWidget {
  final int id;
  final DateTime data;
  final String origem;
  final String destino;
  final int totalPecas;
  final String usuario;
  final String status;

  const MovimentacaoCard({
    Key? key,
    required this.id,
    required this.data,
    required this.origem,
    required this.destino,
    required this.totalPecas,
    required this.usuario,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definindo cores e estilos para diferentes status
    Color statusColor;
    Color textColor;

    switch (status) {
      case 'Finalizada':
        statusColor = Theme.of(context).colorScheme.primary;
        textColor = Colors.white;
        break;
      // case 'Erro':
      //   statusColor = Color(0xFFdc3545);  // Cor de fundo para status "Falha"
      //   textColor = Colors.white;  // Cor do texto para status "Falha"
      //   break;
      default:
        statusColor = Color(0xFFb9bdbf); // Cor padrão para outros status
        textColor = Theme.of(context).colorScheme.primary;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/nova_mov',
          arguments: {
            'id': id,
            'status': status,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 6),
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
                    Row(children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 25.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '$id',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ]),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(data.toLocal()),
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
                        horizontal: 7.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 95,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: textColor,
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
