import 'package:flutter/material.dart';

class DialogoErro extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final double alturaMinimaTexto;
  final String? textoBotao1;
  final VoidCallback? onBotao1Pressed;
  final String? textoBotao2;
  final VoidCallback? onBotao2Pressed;

  const DialogoErro({
    Key? key,
    this.titulo = 'Atenção!',
    required this.mensagem,
    this.alturaMinimaTexto = 40,
    this.textoBotao1,
    this.onBotao1Pressed,
    this.textoBotao2,
    this.onBotao2Pressed,
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
            if (textoBotao1 != null && onBotao1Pressed != null)
              Row(
                children: [
                  if (textoBotao1 != null && onBotao1Pressed != null) ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: Text(textoBotao1!),
                        onPressed: onBotao1Pressed,
                      ),
                    ),
                    if (textoBotao2 != null && onBotao2Pressed != null)
                      SizedBox(width: 30),
                  ],
                  if (textoBotao2 != null && onBotao2Pressed != null)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: Text(textoBotao2!),
                        onPressed: onBotao2Pressed,
                      ),
                    ),
                ],
              ),
            if (textoBotao1 == null && textoBotao2 == null)
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