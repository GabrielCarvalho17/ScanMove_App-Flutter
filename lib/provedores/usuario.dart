import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/servicos/sqlite.dart';

class ProvUsuario with ChangeNotifier {
  String _username = '';
  String _token = '';
  final SQLite _dbHelper = SQLite();

  String get username => _username;
  String get token => _token;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  Future<void> saveUser(String username, String token, String refreshToken) async {
    print('Salvando usuário no SQLite');
    final List<Map<String, dynamic>> users = await _dbHelper.listar('USUARIO');

    if (users.isNotEmpty) {
      // Atualiza o usuário existente
      final int userId = users.first['id'];
      await _dbHelper.atualizar(
        'USUARIO',
        {
          'username': username,
          'access_token': token,
          'refresh_token': refreshToken,
        },
        column: 'id',
        valor: userId,
      );
    } else {
      // Insere um novo usuário
      await _dbHelper.inserir('USUARIO', {
        'username': username,
        'access_token': token,
        'refresh_token': refreshToken,
      });
    }

    setUsername(username);
    setToken(token);
    print('Usuário salvo: $username, token: $token');
  }

  Future<void> loadUser() async {
    print('Carregando usuário do SQLite');
    final List<Map<String, dynamic>> users = await _dbHelper.listar('USUARIO');
    if (users.isNotEmpty) {
      setUsername(users.first['username']);
      setToken(users.first['access_token']);
      print('Usuário carregado: ${users.first['username']}, token: ${users.first['access_token']}');
    }
  }

  Future<void> logout() async {
    print('Atualizando tokens para nulos no SQLite');
    final List<Map<String, dynamic>> users = await _dbHelper.listar('USUARIO');
    if (users.isNotEmpty) {
      final int userId = users.first['id'];
      await _dbHelper.atualizar(
        'USUARIO',
        {
          'access_token': '',
          'refresh_token': '',
        },
        column: 'id',
        valor: userId,
      );
      setUsername('');
      setToken('');
    }
  }

  Future<void> loadUserOnInit() async {
    await loadUser();
    notifyListeners();
  }
}
