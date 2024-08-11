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
                color: Color(0xFF212529), // Cor hexadecimal aplicada diretamente
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        provUsuario.username.isNotEmpty ? provUsuario.username[0].toUpperCase() : '',
                        style: TextStyle(fontSize: 40.0),
                      ),
                      radius: 40,
                    ),
                    SizedBox(height: 15),
                    Text(
                      provUsuario.username,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    // Adicione o email ou deixe vazio
                    Text(
                      '', // Se desejar adicionar um e-mail ou outro campo, modifique aqui
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
              color: Color(0xFF212529), // Cor hexadecimal aplicada diretamente
            ),
            title: Text(
              'Movimentar',
              style: TextStyle(
                color: Color(0xFF212529), // Cor hexadecimal aplicada diretamente
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                '/nova_mov',
                arguments: {
                  'id': null, // Passa `null` se estiver iniciando uma nova movimentação
                  'status': 'ativo', // Define o status como "ativo"
                },
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.history,
              color: Color(0xFF212529), // Cor hexadecimal aplicada diretamente
            ),
            title: Text(
              'Histórico',
              style: TextStyle(
                color: Color(0xFF212529), // Cor hexadecimal aplicada diretamente
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                '/hist_mov',
                arguments: {
                  'id': provUsuario.username, // Passa o username como parte do mapa
                  'status': 'finalizado', // Adiciona um status ou outro argumento relevante
                },
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Color(0xFF212529), // Cor hexadecimal aplicada diretamente
            ),
            title: Text(
              'Sair',
              style: TextStyle(
                color: Color(0xFF212529), // Cor hexadecimal aplicada diretamente
              ),
            ),
            onTap: () async {
              await provUsuario.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
