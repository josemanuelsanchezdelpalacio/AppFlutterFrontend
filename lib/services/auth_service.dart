import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_proyecto_app/data/auth_response.dart';
import 'package:flutter_proyecto_app/data/usuario.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //metodo para registrar un usuario
  Future<AuthResponse> registrarUsuario(Usuario usuario,
      {bool isGoogleSignIn = false}) async {
    try {
      UserCredential? userCredential;

      if (!isGoogleSignIn) {
        // Validar campos requeridos para registro local
        usuario.validarParaRegistroLocal();

        try {
          userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: usuario.email,
            password: usuario.password!,
          );
        } on FirebaseAuthException catch (e) {
          throw Exception(_mapFirebaseError(e.code));
        }
      }

      final Map<String, dynamic> requestBody = {
        'email': usuario.email,
        if (!isGoogleSignIn) 'password': usuario.password,
        'authProvider': isGoogleSignIn ? 'GOOGLE' : 'LOCAL',
        'idUsuarioFirebase': isGoogleSignIn
            ? usuario.idUsuarioFirebase
            : userCredential?.user?.uid,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        // Revertir creación en Firebase si falla el backend
        if (userCredential != null) {
          await userCredential.user?.delete();
        }
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'El email ya está registrado';
      case 'invalid-email':
        return 'El email no es válido';
      case 'operation-not-allowed':
        return 'La autenticación por email/contraseña no está habilitada';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      default:
        return 'Error en el registro: $code';
    }
  }

  //metodo para iniciar sesion con email y contraseña
  Future<AuthResponse> iniciarSesionCorreoPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error en el inicio de sesion');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  //metodo para que el usuario local pueda recuperar la contraseña
  Future<void> recuperarContrasenia(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Por favor ingresa un email válido');
    }

    try {
      // Primero verificamos con el backend
      final response = await http.post(
        Uri.parse('$baseUrl/solicitar-recuperacion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Si el backend aprueba, enviamos el email de recuperación
        await _firebaseAuth.sendPasswordResetEmail(email: email);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            error['message'] ?? 'No se pudo solicitar la recuperación');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (e) {
      throw Exception('Error al procesar la solicitud: ${e.toString()}');
    }
  }

  //metodo para iniciar sesion con cuenta de google
  Future<AuthResponse> inicioSesionGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Inicio de sesion cancelado');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user?.email == null) {
        throw Exception('No se pudo obtener el email del usuario');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/loginGoogle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userCredential.user!.email,
          'idUsuarioFirebase': userCredential.user!.uid,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 404) {
        //registramos el usuario
        final usuario = Usuario(
          email: userCredential.user!.email!,
          idUsuarioFirebase: userCredential.user!.uid,
          authProvider: 'GOOGLE',
        );

        return await registrarUsuario(usuario, isGoogleSignIn: true);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            error['message'] ?? 'Error al autenticar con Google en el backend');
      }
    } catch (e) {
      throw Exception('Error en el inicio de sesión con Google: $e');
    }
  }

  //metodo para cerrar sesion del usuario local y de google
  Future<void> cerrarSesion() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
