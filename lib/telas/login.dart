import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/usuario.dart';
import 'package:AppEstoqueMP/componentes/alerta.dart';
import 'package:AppEstoqueMP/servicos/autenticacao.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _controladorUsuario = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  String _mensagemErro = '';
  bool _isLoading = false;  // Variável para controlar o estado de carregamento

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
      _isLoading = true;  // Começa o carregamento com atraso
    });

    Timer(const Duration(milliseconds: 500), () async {
      try {
        final servAutenticacao = ServAutenticacao();
        final autenticacao = await servAutenticacao.login(usuario, senha);

        Provider.of<ProvUsuario>(context, listen: false).setUsername(usuario);
        Provider.of<ProvUsuario>(context, listen: false).saveUser(
          usuario,
          autenticacao.accessToken,
          autenticacao.refreshToken,
        );

        Navigator.of(context).pushReplacementNamed('/hist_mov');
      } catch (e) {
        setState(() {
          _mensagemErro = 'Usuário ou senha incorretos';
        });
      } finally {
        setState(() {
          _isLoading = false;  // Para o carregamento após a tentativa
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
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _controladorUsuario,
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controladorSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: TextButton(
                    onPressed: _isLoading ? null : _fazerLogin,  // Desabilita o botão durante o carregamento
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: _isLoading  // Exibe o indicador de carregamento ou o texto do botão
                        ? SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,  // Tamanho reduzido
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
      ),
    );
  }
}
