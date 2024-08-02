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
    await _dbHelper.limparUsuarios();
    await _dbHelper.inserirUsuario({
      'username': username,
      'password': '', // Senha não está sendo usada aqui
      'access_token': token,
      'refresh_token': refreshToken,
    });
    setUsername(username);
    setToken(token);
    print('Usuário salvo: $username, token: $token');
  }

  Future<void> loadUser() async {
    print('Carregando usuário do SQLite');
    final List<Map<String, dynamic>> users = await _dbHelper.obterUsuario();
    if (users.isNotEmpty) {
      setUsername(users.first['username']);
      setToken(users.first['access_token']);
      print('Usuário carregado: ${users.first['username']}, token: ${users.first['access_token']}');
    }
  }

  Future<void> logout() async {
    print('Limpando usuários do SQLite');
    await _dbHelper.limparUsuarios(); // Limpa todos os usuários no logout
    setUsername('');
    setToken('');
  }

  Future<void> loadUserOnInit() async {
    await loadUser();
    notifyListeners();
  }
}
