import 'package:intl/intl.dart';

class MetaAhorro {
  int? id;
  String nombre;
  String categoria;
  double cantidadObjetivo;
  double cantidadActual;
  DateTime fechaObjetivo;
  bool completada;
  
  MetaAhorro({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidadObjetivo,
    this.cantidadActual = 0.0,
    required this.fechaObjetivo,
    this.completada = false,
  });
  
  factory MetaAhorro.fromJson(Map json) {
    return MetaAhorro(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'] ?? '',
      cantidadObjetivo: json['cantidadObjetivo']?.toDouble() ?? 0.0,
      cantidadActual: json['cantidadActual']?.toDouble() ?? 0.0,
      fechaObjetivo: DateTime.parse(json['fechaObjetivo']),
      completada: json['completada'] ?? false,
    );
  }
  
  Map toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'cantidadObjetivo': cantidadObjetivo,
      'cantidadActual': cantidadActual,
      'fechaObjetivo': fechaObjetivo.toIso8601String(),
      'completada': completada,
    };
  }
  
  String formatearCantidad(double cantidad) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return formatoMoneda.format(cantidad);
  }
  
  double get progreso => cantidadObjetivo > 0 
      ? (cantidadActual / cantidadObjetivo).clamp(0.0, 1.0) 
      : 0.0;
  
  int get diasRestantes => fechaObjetivo.difference(DateTime.now()).inDays;
  
  bool get estaVencida => !completada && fechaObjetivo.isBefore(DateTime.now());
  
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

