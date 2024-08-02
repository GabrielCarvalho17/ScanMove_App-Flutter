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
            height: 230.0, // Ajuste a altura conforme necessário
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
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
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              'Movimentar',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/nova_mov', arguments: provUsuario.username);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.history,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              'Histórico',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/hist_mov', arguments: provUsuario.username);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              'Sair',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
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
