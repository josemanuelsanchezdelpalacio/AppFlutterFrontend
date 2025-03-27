enum TipoTransacciones { INGRESO, GASTO }

class Transaccion {
  final int? id;
<<<<<<< HEAD
  final String? nombre;
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  final double cantidad;
  final String descripcion;
  final TipoTransacciones tipoTransaccion;
  final String categoria;
  final DateTime fechaTransaccion;
  final bool transaccionRecurrente;
  final String? frecuenciaRecurrencia;
  final DateTime? fechaFinalizacionRecurrencia;
<<<<<<< HEAD
  final String? imagenUrl;
  final int? presupuestoId;
  final int? metaAhorroId;

  Transaccion({
    this.id,
    this.nombre,
=======

  Transaccion({
    this.id,
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    required this.cantidad,
    required this.descripcion,
    required this.tipoTransaccion,
    required this.categoria,
    required this.fechaTransaccion,
    required this.transaccionRecurrente,
    this.frecuenciaRecurrencia,
    this.fechaFinalizacionRecurrencia,
<<<<<<< HEAD
    this.imagenUrl,
    this.presupuestoId,
    this.metaAhorroId,
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'],
<<<<<<< HEAD
      nombre: json['nombre'],
      cantidad: json['cantidad']?.toDouble() ?? 0.0,
      descripcion: json['descripcion'],
      tipoTransaccion: TipoTransacciones.values.firstWhere(
        (e) => e.toString() == 'TipoTransacciones.${json['tipoTransaccion']}',
        orElse: () => TipoTransacciones.GASTO,
=======
      cantidad: json['cantidad']?.toDouble() ?? json['cantidad']?.toDouble() ?? 0.0,
      descripcion: json['descripcion'],
      tipoTransaccion: TipoTransacciones.values.firstWhere(
        (e) => e.toString() == 'TipoTransacciones.${json['tipoTransaccion']}',
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
      ),
      categoria: json['categoria'],
      fechaTransaccion: DateTime.parse(json['fechaTransaccion']),
      transaccionRecurrente: json['transaccionRecurrente'] ?? false,
      frecuenciaRecurrencia: json['frecuenciaRecurrencia'],
      fechaFinalizacionRecurrencia: json['fechaFinalizacionRecurrencia'] != null
          ? DateTime.parse(json['fechaFinalizacionRecurrencia'])
          : null,
<<<<<<< HEAD
      imagenUrl: json['imagenUrl'],
      presupuestoId: json['presupuestoId'],
      metaAhorroId: json['metaAhorroId'],
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
<<<<<<< HEAD
      if (nombre != null) 'nombre': nombre,
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
      'cantidad': cantidad,
      'descripcion': descripcion,
      'tipoTransaccion': tipoTransaccion.toString().split('.').last,
      'categoria': categoria,
      'fechaTransaccion': fechaTransaccion.toIso8601String(),
      'transaccionRecurrente': transaccionRecurrente,
      if (frecuenciaRecurrencia != null)
        'frecuenciaRecurrencia': frecuenciaRecurrencia,
      if (fechaFinalizacionRecurrencia != null)
        'fechaFinalizacionRecurrencia':
            fechaFinalizacionRecurrencia!.toIso8601String(),
<<<<<<< HEAD
      if (imagenUrl != null) 'imagenUrl': imagenUrl,
      if (presupuestoId != null) 'presupuestoId': presupuestoId,
      if (metaAhorroId != null) 'metaAhorroId': metaAhorroId,
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    };
  }
}

