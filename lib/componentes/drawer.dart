import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  Future<String> _obterUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_logado') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _obterUsuarioLogado(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Center(child: CircularProgressIndicator()), // Mostra um indicador de carregamento enquanto obtém o usuário
          );
        }

        if (snapshot.hasError) {
          return Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Center(child: Text('Erro ao carregar usuário')),
          );
        }

        final username = snapshot.data ?? '';

        return Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 200.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF212529),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : '',
                            style: TextStyle(fontSize: 40.0),
                          ),
                          radius: 40,
                        ),
                        SizedBox(height: 15),
                        Text(
                          username,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          '',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.add_circle,
                  color: Color(0xFF212529),
                ),
                title: Text(
                  'Movimentar',
                  style: TextStyle(
                    color: Color(0xFF212529),
                  ),
                ),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushReplacementNamed(
                        '/nova_mov',
                        arguments: {
                          'id': null,
                          'status': 'ativo',
                        },
                      );
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: Color(0xFF212529),
                ),
                title: Text(
                  'Histórico',
                  style: TextStyle(
                    color: Color(0xFF212529),
                  ),
                ),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushReplacementNamed(
                        '/hist_mov',
                        arguments: {
                          'id': username,
                          'status': 'finalizado',
                        },
                      );
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: Color(0xFF212529),
                ),
                title: Text(
                  'Sair',
                  style: TextStyle(
                    color: Color(0xFF212529),
                  ),
                ),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('usuario_logado'); // Limpa o usuário logado
                  if (Navigator.canPop(context)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
