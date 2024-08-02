import 'package:flutter/material.dart';

class MsgErro extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const MsgErro({
    Key? key,
    required this.message,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Altura fixa para o espaço da mensagem
      child: message.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
