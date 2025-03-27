enum TipoTransacciones { INGRESO, GASTO }

class Transaccion {
  final int? id;
  final String? nombre;
  final double cantidad;
  final String descripcion;
  final TipoTransacciones tipoTransaccion;
  final String categoria;
  final DateTime fechaTransaccion;
  final bool transaccionRecurrente;
  final String? frecuenciaRecurrencia;
  final DateTime? fechaFinalizacionRecurrencia;
  final String? imagenUrl;
  final int? presupuestoId;
  final int? metaAhorroId;

  Transaccion({
    this.id,
    this.nombre,
    required this.cantidad,
    required this.descripcion,
    required this.tipoTransaccion,
    required this.categoria,
    required this.fechaTransaccion,
    required this.transaccionRecurrente,
    this.frecuenciaRecurrencia,
    this.fechaFinalizacionRecurrencia,
    this.imagenUrl,
    this.presupuestoId,
    this.metaAhorroId,
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'],
      nombre: json['nombre'],
      cantidad: json['cantidad']?.toDouble() ?? 0.0,
      descripcion: json['descripcion'],
      tipoTransaccion: TipoTransacciones.values.firstWhere(
        (e) => e.toString() == 'TipoTransacciones.${json['tipoTransaccion']}',
        orElse: () => TipoTransacciones.GASTO,
      ),
      categoria: json['categoria'],
      fechaTransaccion: DateTime.parse(json['fechaTransaccion']),
      transaccionRecurrente: json['transaccionRecurrente'] ?? false,
      frecuenciaRecurrencia: json['frecuenciaRecurrencia'],
      fechaFinalizacionRecurrencia: json['fechaFinalizacionRecurrencia'] != null
          ? DateTime.parse(json['fechaFinalizacionRecurrencia'])
          : null,
      imagenUrl: json['imagenUrl'],
      presupuestoId: json['presupuestoId'],
      metaAhorroId: json['metaAhorroId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
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
      if (imagenUrl != null) 'imagenUrl': imagenUrl,
      if (presupuestoId != null) 'presupuestoId': presupuestoId,
      if (metaAhorroId != null) 'metaAhorroId': metaAhorroId,
    };
  }
}

