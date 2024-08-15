import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:AppEstoqueMP/servicos/localizacao.dart';
import 'package:AppEstoqueMP/modelos/localizacao.dart';
import 'package:AppEstoqueMP/provedores/movimentacao.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';

class OrigemDestino extends StatefulWidget implements PreferredSizeWidget {
  const OrigemDestino({Key? key}) : super(key: key);

  @override
  _OrigemDestinoState createState() => _OrigemDestinoState();

  @override
  Size get preferredSize => Size.fromHeight(125.0);
}

class _OrigemDestinoState extends State<OrigemDestino> {
  late MovimentacaoProvider movimentacaoProvider;
  final ServLocalizacao _servicoLocalizacao = ServLocalizacao();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    movimentacaoProvider = Provider.of<MovimentacaoProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    final origem = movimentacaoProvider.origem ?? '';
    final destino = movimentacaoProvider.destino ?? '';
    final totalPecas = movimentacaoProvider.totalPecas;

    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _scanBarcode(context, true),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: origem),
                        textAlign: TextAlign.center,
                        readOnly: true,
                        focusNode: AlwaysFocusedNode(),
                        decoration: InputDecoration(
                          labelText: 'Origem',
                          labelStyle:
                              TextStyle(color: Colors.white, fontSize: 18.0),
                          hintStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(Icons.arrow_right, size: 30, color: Colors.white),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _scanBarcode(context, false),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: destino),
                        textAlign: TextAlign.center,
                        readOnly: true,
                        focusNode: AlwaysFocusedNode(),
                        decoration: InputDecoration(
                          labelText: 'Destino',
                          labelStyle:
                              TextStyle(color: Colors.white, fontSize: 18.0),
                          hintStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total de Peças',
                      style: TextStyle(color: Colors.white, fontSize: 17)),
                  Text('$totalPecas',
                      style: TextStyle(color: Colors.white, fontSize: 17)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context, bool isOrigem) async {
    bool loadingExibido = false;
    Timer? timer;

    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        // Inicia o timer para exibir o loading após 1 segundo
        timer = Timer(Duration(seconds: 1), () {
          loadingExibido = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogo(
                titulo: 'Aguarde',
                mensagem: 'Processando, por favor aguarde...',
                isLoading: true,
              );
            },
          );
        });

        // Chama o serviço para obter a localização com base no código escaneado
        var resultado =
            await _servicoLocalizacao.fetchLocalizacao(result.rawContent);

        // Cancela o timer se a resposta for recebida antes de exibir o loading
        if (timer != null && timer.isActive) {
          timer.cancel();
        }

        // Fecha o diálogo de loading se ele estiver sendo exibido
        if (loadingExibido && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        // Interpreta o status retornado pelo serviço
        switch (resultado['status']) {
          case StatusLocalizacao.sucesso:
            LocalizacaoModel localizacao = resultado['localizacao'];
            if (isOrigem) {
              movimentacaoProvider.setOrigem(localizacao.localizacao);
              movimentacaoProvider.setFilialOrigem(localizacao.filial);
            } else {
              movimentacaoProvider.setDestino(localizacao.localizacao);
              movimentacaoProvider.setFilialDestino(localizacao.filial);
            }
            break;
          case StatusLocalizacao.timeout:
            // Exibe o diálogo de erro imediatamente se o servidor não responder
            _mostrarDialogoErro(context, 'Erro',
                'O servidor não está respondendo no momento. Tente novamente mais tarde.');
            break;
          case StatusLocalizacao.semConexao:
            _mostrarDialogoErro(context, 'Erro',
                'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.');
            break;
          case StatusLocalizacao.localizacaoNaoEncontrada:
            _mostrarDialogoErro(
                context, 'Atenção', 'Localização não encontrada.');
            break;
          case StatusLocalizacao.erroServidor:
          default:
            _mostrarDialogoErro(context, 'Erro',
                'Erro ao buscar dados da localização. Tente novamente mais tarde.');
            break;
        }
      }
    } catch (e) {
      // Se ocorrer qualquer erro inesperado
      if (loadingExibido && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _mostrarDialogoErro(context, 'Erro', e.toString().split(': ').last);
    } finally {
      // Certifica-se de fechar o diálogo de loading antes de abrir o diálogo de erro
      if (loadingExibido && Navigator.canPop(context)) {
        Navigator.of(context).pop();
        _mostrarDialogoErro(context, 'Erro',
            'O servidor não está respondendo no momento. Tente novamente mais tarde.');
      }
    }
  }

  void _mostrarDialogoErro(
      BuildContext context, String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogo(
          titulo: titulo,
          mensagem: mensagem,
        );
      },
    );
  }
}

class AlwaysFocusedNode extends FocusNode {
  @override
  bool get hasFocus => true;
}
