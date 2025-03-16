enum TipoTransacciones { INGRESO, GASTO }

class Transaccion {
  final int? id;
  final double cantidad;
  final String descripcion;
  final TipoTransacciones tipoTransaccion;
  final String categoria;
  final DateTime fechaTransaccion;
  final bool transaccionRecurrente;
  final String? frecuenciaRecurrencia;
  final DateTime? fechaFinalizacionRecurrencia;

  Transaccion({
    this.id,
    required this.cantidad,
    required this.descripcion,
    required this.tipoTransaccion,
    required this.categoria,
    required this.fechaTransaccion,
    required this.transaccionRecurrente,
    this.frecuenciaRecurrencia,
    this.fechaFinalizacionRecurrencia,
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'],
      cantidad: json['cantidad']?.toDouble() ?? json['cantidad']?.toDouble() ?? 0.0,
      descripcion: json['descripcion'],
      tipoTransaccion: TipoTransacciones.values.firstWhere(
        (e) => e.toString() == 'TipoTransacciones.${json['tipoTransaccion']}',
      ),
      categoria: json['categoria'],
      fechaTransaccion: DateTime.parse(json['fechaTransaccion']),
      transaccionRecurrente: json['transaccionRecurrente'] ?? false,
      frecuenciaRecurrencia: json['frecuenciaRecurrencia'],
      fechaFinalizacionRecurrencia: json['fechaFinalizacionRecurrencia'] != null
          ? DateTime.parse(json['fechaFinalizacionRecurrencia'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
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
    };
  }
}

