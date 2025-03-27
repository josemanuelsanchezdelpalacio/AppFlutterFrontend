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
<<<<<<< HEAD
  }) : 
    this.cantidadGastada = cantidadGastada ?? 0.0,
    this.cantidadRestante = cantidadRestante ?? (cantidad - (cantidadGastada ?? 0.0));
  
  factory Presupuesto.fromJson(Map json) {
    //parseo de datos Date
=======
  })  : cantidadGastada = cantidadGastada ?? 0.0,
        cantidadRestante = cantidadRestante ??
            (cantidadGastada != null ? cantidad - cantidadGastada : cantidad);

  factory Presupuesto.fromJson(Map<String, dynamic> json) {
    // Parse dates safely
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    DateTime parseDate(dynamic dateStr) {
      try {
        return dateStr is String ? DateTime.parse(dateStr) : DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

<<<<<<< HEAD
    //parseo de datos Double
=======
    // Safely convert to double with default
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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

<<<<<<< HEAD
  Map toJson() {
=======
  Map<String, dynamic> toJson() {
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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

<<<<<<< HEAD
  // Método para actualizar un presupuesto con una transacción
=======
  //metodo para actualizar un presupueso con una transaccion
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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

<<<<<<< HEAD
  // Método para comprobar si una transacción se aplica a este presupuesto
=======
  //metodo para comprobar si una transaccion applies se aplica a este presupuesto
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  bool isTransactionApplicable(DateTime transactionDate) {
    return !transactionDate.isBefore(fechaInicio) &&
        !transactionDate.isAfter(fechaFin);
  }
}
<<<<<<< HEAD


=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
