import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isRegistering = false;
  String _name = '';
  
  Future<void> _authenticate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      try {
        bool success;
        
        if (_isRegistering) {
          success = await _authService.register(_email, _password, _name);
        } else {
          success = await _authService.signIn(_email, _password);
        }
        
        if (success) {
          widget.onLoginSuccess();
        } else {
          setState(() {
            _errorMessage = _isRegistering
                ? 'Błąd podczas rejestracji. Spróbuj ponownie.'
                : 'Nieprawidłowy email lub hasło.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Błąd: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Rejestracja' : 'Logowanie'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/mammoth.png',
                  height: 120,
                ),
                const SizedBox(height: 32),
                
                if (_isRegistering)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Imię i nazwisko',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (_isRegistering && (value == null || value.isEmpty)) {
                        return 'Wprowadź imię i nazwisko';
                      }
                      return null;
                    },
                    onChanged: (value) => _name = value.trim(),
                  ),
                
                if (_isRegistering) const SizedBox(height: 16),
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź adres email';
                    }
                    return null;
                  },
                  onChanged: (value) => _email = value.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Hasło',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź hasło';
                    }
                    if (_isRegistering && value.length < 6) {
                      return 'Hasło musi mieć co najmniej 6 znaków';
                    }
                    return null;
                  },
                  onChanged: (value) => _password = value,
                ),
                const SizedBox(height: 8),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isRegistering ? 'ZAREJESTRUJ SIĘ' : 'ZALOGUJ SIĘ'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistering = !_isRegistering;
                      _errorMessage = '';
                    });
                  },
                  child: Text(
                    _isRegistering
                        ? 'Masz już konto? Zaloguj się'
                        : 'Nie masz konta? Zarejestruj się',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PublicType {}