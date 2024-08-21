import 'package:flutter/material.dart';
import 'package:AppEstoqueMP/servicos/autenticacao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProvUsuario with ChangeNotifier {
  String _username = '';
  String _token = '';
  String _refreshToken = '';
  final ServAutenticacao _authService = ServAutenticacao();

  String get username => _username;
  String get token => _token;

  Future<void> login(String username, String password) async {
    final autenticacao = await _authService.login(username, password);
    _username = username;
    _token = autenticacao.accessToken;
    _refreshToken = autenticacao.refreshToken;
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _username = '';
    _token = '';
    _refreshToken = '';
    await _clearPreferences();
    notifyListeners();
  }

  Future<void> loadUserOnInit() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('usuario_logado') ?? '';
    _token = prefs.getString('token') ?? '';
    _refreshToken = prefs.getString('refreshToken') ?? '';
    notifyListeners();
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_logado', _username);
    await prefs.setString('token', _token);
    await prefs.setString('refreshToken', _refreshToken);
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_logado');
    await prefs.remove('token');
    await prefs.remove('refreshToken');
  }
}
