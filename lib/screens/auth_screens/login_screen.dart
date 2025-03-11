import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/models/login_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/auth_screens/dialog_recuperar_contrasenia.dart';
import 'package:flutter_proyecto_app/screens/auth_screens/registro_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Theme(
        data: AppTheme.obtenerTema(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.security, color: AppTheme.naranja),
                onPressed: () => _mostrarInfoSeguridad(context),
                tooltip: 'Informacion de seguridad',
              ),
            ],
          ),
          body: const LoginForm(),
        ),
      ),
    );
  }

  void _mostrarInfoSeguridad(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.colorFondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: AppTheme.naranja, width: 2),
          ),
          title: const Text(
            'Seguridad de tus datos',
            style: TextStyle(
              color: AppTheme.naranja,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoSection(
                  'Autenticacion Local',
                  'Tus credenciales se almacenan en una base de datos local encriptada. Esta informacion nunca se comparte con terceros y solo se utiliza para verificar tu identidad dentro de la aplicacion.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Autenticacion con Google',
                  'Al iniciar sesion con Google se usa Firebase Authentication para gestionar tu acceso de forma segura. Solo obtenemos tu correo electrónico y nombre para crear tu perfil. No se tiene acceso a tu contraseña de Google.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Compromiso de Privacidad',
                  'No se comparten ni se vende tu informacion personal a terceros',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: AppTheme.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _infoSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.naranja,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            color: AppTheme.blanco,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _mostrarDialogoRecuperacion(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return DialogRecuperarContrasenia(
          viewModel: Provider.of<LoginViewModel>(context, listen: false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagen del logo
                Image.asset(
                  'lib/assets/imagen_logo.png',
                  fit: BoxFit.contain,
                  height: 180,
                ),
                const SizedBox(height: 40),

                //campo de email
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: AppTheme.blanco),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    // Validación de formato de email
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                //campo de contraseña
                TextFormField(
                  controller: passwordController,
                  style: const TextStyle(color: AppTheme.blanco),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _mostrarDialogoRecuperacion(context),
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                //boton de inicio de sesion
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: viewModel.loading
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              viewModel.iniciarSesion(
                                emailController.text,
                                passwordController.text,
                                context,
                              );
                            }
                          },
                    child: viewModel.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.colorFondo,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Iniciar sesion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  'O continua con',
                  style: TextStyle(
                    color: AppTheme.blanco,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                //boton de inicio con Google
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    icon:
                        Image.asset('lib/assets/google_logo.png', height: 24.0),
                    label: const Text(
                      'Continuar con Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: viewModel.loading
                        ? null
                        : () => viewModel.iniciarSesionConGoogle(context),
                  ),
                ),

                const SizedBox(height: 30),

                //navegar a pantalla de registro
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistroScreen()),
                    );
                  },
                  child: const Text(
                    '¿No tienes cuenta? Registrate',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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
