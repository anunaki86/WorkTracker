import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../models/user.dart';

class AuthService {
  final _logger = Logger('AuthService');
  static const String _userKey = 'users';
  static const String _currentUserKey = 'current_user';
  Future<void> createDefaultAdminIfNeeded() async {
  final users = await _getUsers();
  if (users.isEmpty) {
    // Tworzymy domyślne konto administratora, jeśli nie ma żadnych użytkowników
    await register(
      'admin@example.com', 
      'admin123', 
      'Administrator'
    );
    _logger.info('Utworzono domyślne konto administratora');
  }
}

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }
  
  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_currentUserKey);
    if (userString == null) return null;
    
    return AppUser.fromJson(jsonDecode(userString));
  }
  
  Future<List<AppUser>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList(_userKey) ?? [];
    
    return usersList
        .map((userString) => AppUser.fromJson(jsonDecode(userString)))
        .toList();
  }
  
  Future<void> _saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = users
        .map((user) => jsonEncode(user.toJson()))
        .toList();
    
    await prefs.setStringList(_userKey, usersList);
  }
  
  Future<bool> signIn(String email, String password) async {
    try {
      _logger.info('Próba logowania: $email');
      final users = await _getUsers();
      
      final user = users.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => throw Exception('Nieprawidłowy email lub hasło'),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      
      _logger.info('Zalogowany użytkownik: $email');
      return true;
    } catch (e) {
      _logger.severe('Błąd logowania: $e');
      return false;
    }
  }
  
  Future<bool> register(String email, String password, String? name) async {
    try {
      _logger.info('Próba rejestracji: $email');
      final users = await _getUsers();
      
      // Sprawdź, czy użytkownik już istnieje
      final userExists = users.any((user) => user.email == email);
      if (userExists) {
        throw Exception('Użytkownik o podanym adresie email już istnieje');
      }
      
      // Utwórz nowego użytkownika
      final newUser = AppUser(
        email: email,
        password: password, // W prawdziwej aplikacji użyj bezpiecznego hashowania
        name: name,
      );
      
      users.add(newUser);
      await _saveUsers(users);
      
      // Automatycznie zaloguj nowego użytkownika
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));
      
      _logger.info('Zarejestrowany nowy użytkownik: $email');
      return true;
    } catch (e) {
      _logger.severe('Błąd rejestracji: $e');
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      _logger.info('Użytkownik wylogowany');
    } catch (e) {
      _logger.severe('Błąd wylogowania: $e');
      rethrow;
    }
  }
}