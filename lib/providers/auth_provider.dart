import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String get role => _user?.role ?? '';

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    if (token == null) return;
    api.setToken(token);
    try {
      final data = await api.getUser();
      _user = UserModel.fromJson(data['user']);
      notifyListeners();
    } catch (_) {
      api.setToken(null);
      await prefs.remove('api_token');
    }
  }

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await api.login(username, password);
      _user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;
      api.setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', token);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String username, String email, String password, String displayName) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await api.register(username, email, password, displayName);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPw, String newPw) async {
    try {
      await api.changePassword(oldPw, newPw);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void logout() async {
    _user = null;
    api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    notifyListeners();
  }
}
