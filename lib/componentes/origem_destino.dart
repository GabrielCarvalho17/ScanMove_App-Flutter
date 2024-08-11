import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/componentes/dialogo.dart';
import 'package:AppEstoqueMP/servicos/localizacao.dart';
import 'package:AppEstoqueMP/provedores/origem_destino.dart';
import 'package:AppEstoqueMP/provedores/peca.dart';

class FormOrigemDestino extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, String>? dados;
  final bool isReadOnly;

  const FormOrigemDestino({Key? key, this.dados, this.isReadOnly = false}) : super(key: key);

  @override
  _FormOrigemDestinoState createState() => _FormOrigemDestinoState();

  @override
  Size get preferredSize => Size.fromHeight(80.0);
}

class _FormOrigemDestinoState extends State<FormOrigemDestino> {
  late TextEditingController origemController;
  late TextEditingController destinoController;
  final ServLocalizacao _servLocalizacao = ServLocalizacao();

  @override
  void initState() {
    super.initState();
    origemController = TextEditingController();
    destinoController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _atualizarControladoresEProvedor();
    });
  }

  void _atualizarControladoresEProvedor() {
    final provOrigemDestino = Provider.of<ProvOrigemDestino>(context, listen: false);

    if (widget.dados != null) {
      origemController.text = widget.dados!['origem']!;
      destinoController.text = widget.dados!['destino'] ?? '';

      provOrigemDestino.setOrigem(widget.dados!['origem']!, filial: widget.dados!['filial_origem']!);
      provOrigemDestino.setDestino(widget.dados!['destino'] ?? '', filial: widget.dados!['filial_destino'] ?? '');
    } else {
      origemController.text = provOrigemDestino.origem;
      destinoController.text = provOrigemDestino.destino;
    }

    origemController.addListener(() {
      final provPeca = Provider.of<ProvPeca>(context, listen: false);
      if (provOrigemDestino.origem != origemController.text) {
        if (provPeca.ultimaLocalizacao.isNotEmpty && provPeca.ultimaLocalizacao != origemController.text) {
          origemController.text = provOrigemDestino.origem;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return DialogoErro(
                titulo: 'Atenção',
                mensagem: 'A nova origem não corresponde à localização das peças já adicionadas.',
              );
            },
          );
        } else {
          provOrigemDestino.setOrigem(origemController.text);
        }
      }
    });

    destinoController.addListener(() {
      if (provOrigemDestino.destino != destinoController.text) {
        provOrigemDestino.setDestino(destinoController.text);
      }
    });
  }

  @override
  void didUpdateWidget(covariant FormOrigemDestino oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dados != widget.dados) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _atualizarControladoresEProvedor();
      });
    }
  }

  @override
  void dispose() {
    origemController.dispose();
    destinoController.dispose();
    super.dispose();
  }

  Future<void> insereLocalizacao(TextEditingController controller, String campo) async {
    if (widget.isReadOnly) return;

    var result = await BarcodeScanner.scan();

    if (result.type == ResultType.Barcode) {
      String rawContent = result.rawContent;

      try {
        var localizacao = await _servLocalizacao.fetchLocalizacao(context, rawContent);
        print("Localização obtida: ${localizacao.localizacao}, Filial: ${localizacao.filial}");

        final provOrigemDestino = Provider.of<ProvOrigemDestino>(context, listen: false);
        final provPeca = Provider.of<ProvPeca>(context, listen: false);

        bool validacaoFalhou = false;

        if (campo == 'Origem' && provPeca.ultimaLocalizacao.isNotEmpty && provPeca.ultimaLocalizacao != localizacao.localizacao) {
          validacaoFalhou = true;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return DialogoErro(
                titulo: 'Atenção',
                mensagem: 'A nova origem não corresponde à localização das peças já adicionadas.',
              );
            },
          );
        }

        if (campo == 'Origem' && provOrigemDestino.destino.isNotEmpty && rawContent == provOrigemDestino.destino) {
          validacaoFalhou = true;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return DialogoErro(
                titulo: 'Erro',
                mensagem: 'Origem e destino não podem ser iguais!',
              );
            },
          );
        }

        if (validacaoFalhou) return;

        setState(() {
          controller.text = rawContent;
        });

        if (campo == 'Origem') {
          provOrigemDestino.setOrigem(rawContent, filial: localizacao.filial);
        } else {
          provOrigemDestino.setDestino(rawContent, filial: localizacao.filial);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          verificarOrigemDestino(campo);
        });

      } catch (e) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogoErro(
              titulo: 'Atenção',
              mensagem: errorMessage,
            );
          },
        );

        setState(() {
          controller.clear();
          if (campo == 'Origem') {
            context.read<ProvOrigemDestino>().setOrigem('');
          } else {
            context.read<ProvOrigemDestino>().setDestino('');
          }
        });
      }
    }
  }

  void verificarOrigemDestino(String campo) {
    String origem = context.read<ProvOrigemDestino>().origem;
    String destino = context.read<ProvOrigemDestino>().destino;

    if (origem.isNotEmpty && destino.isNotEmpty && origem == destino) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogoErro(
            titulo: 'Erro',
            mensagem: 'Origem e destino não podem ser iguais!',
          );
        },
      );
      setState(() {
        if (campo == 'Destino') {
          destinoController.clear();
          context.read<ProvOrigemDestino>().setDestino('');
        } else if (campo == 'Origem') {
          origemController.clear();
          context.read<ProvOrigemDestino>().setOrigem('');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProvOrigemDestino>(
      builder: (context, provOrigemDestino, child) {
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
                      child: TextField(
                        controller: origemController,
                        textAlign: TextAlign.center,
                        readOnly: true,
                        focusNode: AlwaysFocusedNode(),
                        decoration: InputDecoration(
                          labelText: 'Origem',
                          hintText: 'Insira a origem',
                          labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
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
                        onTap: widget.isReadOnly ? null : () => insereLocalizacao(origemController, 'Origem'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.arrow_right, size: 30, color: Colors.white),
                    ),
                    Expanded(
                      child: TextField(
                        controller: destinoController,
                        textAlign: TextAlign.center,
                        readOnly: true,
                        focusNode: AlwaysFocusedNode(),
                        decoration: InputDecoration(
                          labelText: 'Destino',
                          hintText: 'Insira o destino',
                          labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
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
                        onTap: widget.isReadOnly
                            ? null
                            : () {
                          if (origemController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return DialogoErro(
                                  titulo: 'Atenção',
                                  mensagem: 'Por favor, preencha o campo de origem primeiro.',
                                );
                              },
                            );
                          } else {
                            insereLocalizacao(destinoController, 'Destino');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AlwaysFocusedNode extends FocusNode {
  @override
  bool get hasFocus => true;
}
