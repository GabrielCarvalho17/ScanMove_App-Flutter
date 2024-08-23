import 'dart:async';
import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/provedores/usuario.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/componentes/alerta.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  bool _isPasswordVisible =
      false; // Variável para controlar a visibilidade da senha

  final TextEditingController _controladorUsuario = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  String _mensagemErro = '';
  bool _isLoading = false; // Variável para controlar o estado de carregamento

  String formatarUsername(String username) {
    return username.trim().toLowerCase();
  }

  void _fazerLogin() async {
    setState(() {
      _mensagemErro = '';
    });

    String usuario = formatarUsername(_controladorUsuario.text);
    String senha = _controladorSenha.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      setState(() {
        _mensagemErro = 'Preencha todos os campos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Timer(const Duration(milliseconds: 200), () async {
      try {
        // Acessa o provedor de usuário
        final provUsuario = Provider.of<ProvUsuario>(context, listen: false);

        // Chama o método login do provedor, que já gerencia o armazenamento
        await provUsuario.login(usuario, senha);

        // Navega para a tela de histórico de movimentações
        Navigator.of(context).pushReplacementNamed('/hist_mov');
      } catch (e) {
        setState(() {
          _mensagemErro = e.toString().replaceAll(
              'Exception: ', ''); // Remove qualquer ocorrência de "Exception: "
        });
      } finally {
        setState(() {
          _isLoading = false; // Para o carregamento após a tentativa
        });
      }
    });
  }

  void _fecharMensagemErro() {
    setState(() {
      _mensagemErro = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Stack(
              children: [
                // Container escuro
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: (screenHeight - keyboardHeight) * 0.35,
                    width: double.infinity,
                    color: Color(0xFF212529),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                              // Calcula a altura da imagem com base na altura da tela disponível
                              height: (screenHeight - keyboardHeight) *
                                  0.20, // Altere o valor conforme necessário
                              child: Image.asset('assets/logo_app.png'),
                            ),
                          ),
                          Text(
                            'ScanMove',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              // Ajusta o tamanho da fonte proporcionalmente ao espaço disponível
                              fontSize: (screenHeight - keyboardHeight) *
                                  0.04, // Ajuste o fator conforme necessário
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Container branco sobreposto
                Positioned(
                  top: (screenHeight - keyboardHeight) * 0.30,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.only(top: 40.0, left: 25, right: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controladorUsuario,
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controladorSenha,
                          obscureText: !_isPasswordVisible, // Oculta o texto
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: TextButton(
                            onPressed: _isLoading ? null : _fazerLogin,
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFF212529),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24.0,
                                    height: 24.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ),
                        const SizedBox(height: 30),
                        MsgErro(
                          message: _mensagemErro,
                          onClose: _fecharMensagemErro,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Copyright na parte inferior, que será sobreposto pelo teclado
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Visibility(
                visible: keyboardHeight == 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo_copyright_kingejoe.png',
                        height: 50,
                      ),
                      Text(
                        'Copyright © Todos os direitos reservados | KING&JOE',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
