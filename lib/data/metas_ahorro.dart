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
  
<<<<<<< HEAD
  factory MetaAhorro.fromJson(Map json) {
=======
  factory MetaAhorro.fromJson(Map<String, dynamic> json) {
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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
  
<<<<<<< HEAD
  Map toJson() {
=======
  Map<String, dynamic> toJson() {
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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
  
<<<<<<< HEAD
  // Formato de moneda
=======
  //formato de moneda
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  String formatearCantidad(double cantidad) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return formatoMoneda.format(cantidad);
  }
  
<<<<<<< HEAD
  // Calculo el progreso
=======
  //calculo el progreso
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  double get progreso => cantidadObjetivo > 0 
      ? (cantidadActual / cantidadObjetivo).clamp(0.0, 1.0) 
      : 0.0;
  
<<<<<<< HEAD
  // Días restantes
  int get diasRestantes => fechaObjetivo.difference(DateTime.now()).inDays;
  
  // Compruebo si está vencida
  bool get estaVencida => !completada && fechaObjetivo.isBefore(DateTime.now());
  
  // Copio con las modificaciones
=======
  //dias restantes
  int get diasRestantes => fechaObjetivo.difference(DateTime.now()).inDays;
  
  //compruebo si esta vencida
  bool get estaVencida => !completada && fechaObjetivo.isBefore(DateTime.now());
  
  //copio con las modificaciones
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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

