import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/models/register_screen_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/auth_screens/login_screen.dart';
import 'package:provider/provider.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistroViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registro'),
        ),
        body: const RegistroForm(),
      ),
    );
  }
}

class RegistroForm extends StatefulWidget {
  const RegistroForm({super.key});

  @override
  State<RegistroForm> createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegistroViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'lib/assets/imagen_logo.png',
                  fit: BoxFit.contain,
                  height: 200,
                ),
              ),
              const SizedBox(height: 24),

              //campo de email
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  //para no permitir los espacios
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un email';
                  }
                  //validacion para el campo del email
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Por favor ingresa un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              //campo de contraseña
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      viewModel.passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      viewModel.togglePasswordVisibility();
                    },
                  ),
                  helperText: 'Mínimo 6 caracteres',
                ),
                obscureText: !viewModel.passwordVisible,
                inputFormatters: [
                  //limito a caracteres comunes en contraseñas
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.loading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            viewModel.registrar(
                              emailController.text,
                              passwordController.text,
                              context,
                            );
                          }
                        },
                  child: viewModel.loading
                      ? const CircularProgressIndicator()
                      : const Text('Registrarse'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


