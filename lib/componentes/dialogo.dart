import 'package:flutter/material.dart';

class DialogoErro extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final double alturaMinimaTexto; // Altura mínima para a área de texto do erro

  const DialogoErro({
    Key? key,
    this.titulo = 'Atenção!',
    required this.mensagem,
    this.alturaMinimaTexto = 40, // Definindo um valor padrão para a altura mínima
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16.0),
            Container(
              constraints: BoxConstraints(
                minHeight: alturaMinimaTexto,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Text(
                  mensagem,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
