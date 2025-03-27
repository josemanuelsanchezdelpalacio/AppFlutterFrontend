class Presupuesto {
  final int? id;
  final String? nombre;
  final String categoria;
  final double cantidad;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double cantidadGastada;
  final double cantidadRestante;

  Presupuesto({
    this.id,
    this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.fechaInicio,
    required this.fechaFin,
    double? cantidadGastada,
    double? cantidadRestante,
  }) : 
    this.cantidadGastada = cantidadGastada ?? 0.0,
    this.cantidadRestante = cantidadRestante ?? (cantidad - (cantidadGastada ?? 0.0));
  
  factory Presupuesto.fromJson(Map json) {
    //parseo de datos Date
    DateTime parseDate(dynamic dateStr) {
      try {
        return dateStr is String ? DateTime.parse(dateStr) : DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    //parseo de datos Double
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
    };
  }

  // Método para actualizar un presupuesto con una transacción
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
    );
  }

  // Método para comprobar si una transacción se aplica a este presupuesto
  bool isTransactionApplicable(DateTime transactionDate) {
    return !transactionDate.isBefore(fechaInicio) &&
        !transactionDate.isAfter(fechaFin);
  }
}


