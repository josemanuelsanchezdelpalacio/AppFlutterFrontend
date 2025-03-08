import 'package:intl/intl.dart';

class MetaAhorro {
  int? id;
  String nombre;
  String categoria; // Separate categoria field
  double cantidadObjetivo;
  double cantidadActual;
  DateTime fechaObjetivo;
  bool completada;
  
  MetaAhorro({
    this.id,
    required this.nombre,
    required this.categoria, // Added categoria to constructor
    required this.cantidadObjetivo,
    this.cantidadActual = 0.0,
    required this.fechaObjetivo,
    this.completada = false,
  });
  
  factory MetaAhorro.fromJson(Map<String, dynamic> json) {
    return MetaAhorro(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'] ?? '', // Ensure categoria is parsed
      cantidadObjetivo: json['cantidadObjetivo']?.toDouble() ?? 0.0,
      cantidadActual: json['cantidadActual']?.toDouble() ?? 0.0,
      fechaObjetivo: DateTime.parse(json['fechaObjetivo']),
      completada: json['completada'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'categoria': categoria, // Include categoria in JSON
      'cantidadObjetivo': cantidadObjetivo,
      'cantidadActual': cantidadActual,
      'fechaObjetivo': fechaObjetivo.toIso8601String(),
      'completada': completada,
    };
  }
  
  // Formato de moneda
  String formatearCantidad(double cantidad) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return formatoMoneda.format(cantidad);
  }
  
  // Calcular progreso
  double get progreso => cantidadObjetivo > 0 
      ? (cantidadActual / cantidadObjetivo).clamp(0.0, 1.0) 
      : 0.0;
  
  // Días restantes
  int get diasRestantes => fechaObjetivo.difference(DateTime.now()).inDays;
  
  // Verificar si está vencida
  bool get estaVencida => !completada && fechaObjetivo.isBefore(DateTime.now());
  
  // Copiar con modificaciones
  MetaAhorro copyWith({
    int? id,
    String? nombre,
    String? categoria,
    double? cantidadObjetivo,
    double? cantidadActual,
    DateTime? fechaObjetivo,
    bool? completada,
  }) {
    return MetaAhorro(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      cantidadObjetivo: cantidadObjetivo ?? this.cantidadObjetivo,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      fechaObjetivo: fechaObjetivo ?? this.fechaObjetivo,
      completada: completada ?? this.completada,
    );
  }
}