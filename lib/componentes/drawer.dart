import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AppEstoqueMP/provedores/usuario.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provUsuario = Provider.of<ProvUsuario>(context);

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
                        provUsuario.username.isNotEmpty
                            ? provUsuario.username[0].toUpperCase()
                            : '',
                        style: TextStyle(fontSize: 40.0),
                      ),
                      radius: 40,
                    ),
                    SizedBox(height: 15),
                    Text(
                      provUsuario.username,
                      style: TextStyle(color: Colors.white, fontSize: 20),
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
                      'id': provUsuario.username,
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
              final provUsuario = Provider.of<ProvUsuario>(context, listen: false);
              await provUsuario.logout();
              // Substitui todas as rotas anteriores pela rota de login
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
