import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/telas/detalhes_mov.dart';

class Movimentacao extends StatelessWidget {
  final String id;
  final DateTime data;
  final int numero;
  final String origemDestino;
  final int totalPecas;
  final String usuario;
  final DateTime dataHora;

  const Movimentacao({
    Key? key,
    required this.id,
    required this.data,
    required this.numero,
    required this.origemDestino,
    required this.totalPecas,
    required this.usuario,
    required this.dataHora,
  }) : super(key: key);

  void _navegarParaDetalhes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetalhesMov(id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Separar origem e destino
    final origem = origemDestino.split(' -> ')[0];
    final destino = origemDestino.split(' -> ')[1];

    return GestureDetector(
      onTap: () => _navegarParaDetalhes(context),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Cor de fundo do ícone
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Icon(
                    Icons.swap_horiz,
                    size: 30.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '# $numero',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${dataHora.toLocal().toString().split(' ')[0]} ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'De: $origem Para: $destino',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Autor: $usuario',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Total: $totalPecas',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
