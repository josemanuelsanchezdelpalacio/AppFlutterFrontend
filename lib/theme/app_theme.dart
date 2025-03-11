import 'package:flutter/material.dart';

class AppTheme {

  static const Color colorFondo = Color(0xFF121212);
  static const Color naranja = Color(0xFFFFA500);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color gris = Color(0xFF2A2A2A);
  
  // Actualizada para coincidir con la ruta usada en LoginScreen
  static const String rutaLogo = 'lib/assets/imagen_logo.png';
  
  static ThemeData obtenerTema() {
    return ThemeData(
      
      scaffoldBackgroundColor: colorFondo,

      appBarTheme: const AppBarTheme(
        backgroundColor: colorFondo,
        foregroundColor: blanco,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gris,
        labelStyle: const TextStyle(color: blanco),
        prefixIconColor: const Color.fromARGB(255, 255, 196, 0),
        suffixIconColor: naranja,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: naranja, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: naranja,
          foregroundColor: colorFondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: blanco),
        bodyMedium: TextStyle(color: blanco),
        titleLarge: TextStyle(color: blanco),
      )
    );
  }
}

