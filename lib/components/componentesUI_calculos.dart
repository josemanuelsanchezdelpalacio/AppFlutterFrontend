import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';

class ComponentesuiCalculos {

  static Widget buildSeccionTitulo(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.naranja,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget buildCampos({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.gris.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.blanco),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.naranja),
          prefixIcon: Icon(prefixIcon, color: AppTheme.naranja),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  static Widget buildCampoDeslizante({

    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.naranja,
            fontSize: 16,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions ?? (max - min).toInt(),
          activeColor: AppTheme.naranja,
          inactiveColor: AppTheme.gris,
          onChanged: onChanged,
        ),
      ],
    );
  }

  static Widget buildItemResultados({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.blanco,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


