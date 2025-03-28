import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/usuario.dart';
import 'package:flutter_proyecto_app/screens/auth_screens/login_screen.dart';
import 'package:flutter_proyecto_app/services/auth_service.dart';

class RegistroViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _mensajeError;
  bool _passwordVisible = false;

  bool get loading => _isLoading;
  String? get mensajeError => _mensajeError;
  bool get passwordVisible => _passwordVisible;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _mensajeError = error;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  Future<void> registrar(
      String email, String password, BuildContext context) async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final usuario = Usuario(
        email: email,
        password: password,
        authProvider: 'LOCAL',
      );

      final respuesta = await _authService.registrarUsuario(usuario);

      if (respuesta.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. Por favor inicia sesión'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception:', '').trim());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mensajeError ?? 'Error en el registro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }
}

