import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  AuthProvider() {
    checkLoginStatus();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  Future<void> checkLoginStatus() async {
    debugPrint('Sprawdzanie statusu logowania...');
    final loggedIn = await _authService.isLoggedIn();
    debugPrint('Status logowania: $loggedIn');
    _isLoggedIn = loggedIn;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login() async {
    debugPrint('Logowanie użytkownika...');
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    debugPrint('Wylogowywanie użytkownika...');
    _isLoggedIn = false;
    notifyListeners();
  }
}
