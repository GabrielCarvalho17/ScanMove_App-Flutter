import 'package:flutter/material.dart';

class DetalhesMov extends StatelessWidget {
  final String id;

  const DetalhesMov({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Supondo que você tenha uma maneira de obter os detalhes da movimentação pelo ID
    final String descricao = 'Descrição da movimentação $id';
    final DateTime data = DateTime.now();
    final double valor = 100.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Movimentação $id'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descricao,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Data: ${data.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Valor: R\$${valor.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
