import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/services/auth_service.dart';

class LoginViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _mensajeError;

  bool get loading => _isLoading;
  String? get mensajeError => _mensajeError;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _mensajeError = error;
    notifyListeners();
  }

  Future<void> iniciarSesion(
      String email, String contrasena, BuildContext context) async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final respuesta = await _authService.iniciarSesionCorreoPassword(
        email: email,
        password: contrasena,
      );

      if (respuesta.success && context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: respuesta.userId,
        );
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception:', '').trim());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mensajeError ?? 'Error al iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> iniciarSesionConGoogle(BuildContext context) async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final respuesta = await _authService.inicioSesionGoogle();

      if (respuesta.success && context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: respuesta.userId,
        );
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception:', '').trim());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_mensajeError ?? 'Error al iniciar sesión con Google'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> recuperarContrasena(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.recuperarContrasenia(email);

      // Si llega aquí, todo fue bien
      _setError(null);
    } catch (e) {
      // Manejar errores específicos
      String errorMessage = e.toString();
      if (errorMessage.contains('firebase')) {
        errorMessage =
            'Error al enviar el correo de recuperación. Por favor intenta nuevamente.';
      } else if (errorMessage.contains('registrado')) {
        errorMessage = 'No existe una cuenta con este email.';
      } else if (errorMessage.contains('GOOGLE')) {
        errorMessage =
            'Este email está registrado con Google. Por favor inicia sesión con Google.';
      }

      _setError(errorMessage.replaceAll('Exception:', '').trim());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
