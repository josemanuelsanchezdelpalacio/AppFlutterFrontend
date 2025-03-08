class Presupuesto {
  final int? id;
  final String? nombre; // Made nullable
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
    cantidadGastada = cantidadGastada ?? 0.0,
    cantidadRestante = cantidadRestante ?? (cantidadGastada != null 
      ? cantidad - cantidadGastada 
      : cantidad);

  factory Presupuesto.fromJson(Map<String, dynamic> json) {
    // Parse dates safely
    DateTime parseDate(dynamic dateStr) {
      try {
        return dateStr is String 
          ? DateTime.parse(dateStr) 
          : DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    // Safely convert to double with default
    double safeDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      return (value is num) 
        ? value.toDouble() 
        : defaultValue;
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

  Map<String, dynamic> toJson() {
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

  // New method to update budget with a transaction
  Presupuesto updateWithTransaction(double transactionAmount) {
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

  // Method to check if a transaction applies to this budget
  bool isTransactionApplicable(DateTime transactionDate) {
    return !transactionDate.isBefore(fechaInicio) && 
           !transactionDate.isAfter(fechaFin);
  }
}

