class Presupuesto {
  final int? id;
  final String? nombre;
  final String categoria;
  final double cantidad;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double cantidadGastada;
  final double cantidadRestante;
  bool completado;

  Presupuesto({
    this.id,
    this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.fechaInicio,
    required this.fechaFin,
    double? cantidadGastada,
    double? cantidadRestante,
    this.completado = false
  }) : 
    this.cantidadGastada = cantidadGastada ?? 0.0,
    this.cantidadRestante = cantidadRestante ?? (cantidad - (cantidadGastada ?? 0.0));
  
  factory Presupuesto.fromJson(Map json) {
    DateTime parseDate(dynamic dateStr) {
      try {
        return dateStr is String ? DateTime.parse(dateStr) : DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    double safeDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      return (value is num) ? value.toDouble() : defaultValue;
    }

    double cantidad = safeDouble(json['cantidad']);
    double cantidadGastada = safeDouble(json['cantidadGastada']);

    return Presupuesto(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'] ?? '',
      cantidad: cantidad,
      fechaInicio: parseDate(json['fechaInicio']),
      fechaFin: parseDate(json['fechaFin']),
      cantidadGastada: cantidadGastada,
      cantidadRestante: cantidad - cantidadGastada,
      completado: json['completado'] ?? false,
    );
  }

  Map toJson() {
    return {
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'cantidadGastada': cantidadGastada,
      'cantidadRestante': cantidadRestante,
      'completado': completado
    };
  }

  Presupuesto actualizarConTransaccion(double transactionAmount) {
    double newCantidadGastada = cantidadGastada + transactionAmount;
    double newCantidadRestante = cantidad - newCantidadGastada;

    return Presupuesto(
      id: id,
      nombre: nombre,
      categoria: categoria,
      cantidad: cantidad,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      cantidadGastada: newCantidadGastada,
      cantidadRestante: newCantidadRestante,
      completado: completado
    );
  }

  bool isTransactionApplicable(DateTime transactionDate) {
    return !transactionDate.isBefore(fechaInicio) &&
        !transactionDate.isAfter(fechaFin);
  }

  int get diasRestantes => fechaFin.difference(DateTime.now()).inDays;
  
  String get textoTiempoRestante {
    final dias = diasRestantes;
    if (dias > 0) {
      return '$dias días restantes';
    } else if (dias == 0) {
      return 'Vence hoy';
    } else {
      return 'Vencido hace ${-dias} días';
    }
  }
}

