import 'package:flutter/foundation.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';

class HomeViewModel extends ChangeNotifier {
  final int userId;

  final TransaccionesService _transaccionesService = TransaccionesService();
  final PresupuestosService _presupuestosService = PresupuestosService();
  final MetasAhorroService _metasAhorroService = MetasAhorroService();

  List<Transaccion> _ultimasTransacciones = [];
  List<Transaccion> _todasTransacciones = [];
  List<Presupuesto> _presupuestos = [];
  List<MetaAhorro> _metasAhorro = [];
  double _balanceTotal = 0;
  double _ingresosTotal = 0;
  double _gastosTotal = 0;

  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();

  bool _isLoading = true;
  String _errorMessage = '';

  // Getters
  List<Transaccion> get ultimasTransacciones => _ultimasTransacciones;
  List<Transaccion> get todasTransacciones => _todasTransacciones;
  List<Presupuesto> get presupuestos => _presupuestos;
  List<MetaAhorro> get metasAhorro => _metasAhorro;
  double get balanceTotal => _balanceTotal;
  double get ingresosTotal => _ingresosTotal;
  double get gastosTotal => _gastosTotal;
  DateTime get fechaInicio => _fechaInicio;
  DateTime get fechaFin => _fechaFin;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  HomeViewModel(this.userId) {
    // Inicialmente mostrar datos del mes actual
    final DateTime ahora = DateTime.now();
    _fechaInicio = DateTime(ahora.year, ahora.month, 1);
    _fechaFin = DateTime(ahora.year, ahora.month + 1, 0);
  }

  void actualizarRangoFechas(DateTime inicio, DateTime fin) {
    _fechaInicio = inicio;
    _fechaFin = fin;
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    _setLoading(true);
    _setError('');

    try {
      // Cargar todas las transacciones dentro del rango de fechas
      final transacciones = await _transaccionesService
          .obtenerTransaccionesPorFecha(userId, _fechaInicio, _fechaFin);

      _todasTransacciones = transacciones;

      // Calcular totales
      double ingresos = 0;
      double gastos = 0;

      for (var transaccion in transacciones) {
        if (transaccion.tipoTransaccion == TipoTransacciones.INGRESO) {
          ingresos += transaccion.cantidad;
        } else if (transaccion.tipoTransaccion == TipoTransacciones.GASTO) {
          gastos += transaccion.cantidad;
        }
      }

      // Obtener presupuestos activos
      final presupuestos =
          await _presupuestosService.obtenerPresupuestos(userId);

      // Filtrar presupuestos activos y reconstruirlos con los gastos calculados
      List<Presupuesto> presupuestosActivos = [];
      for (var presupuesto in presupuestos) {
        if (presupuesto.fechaFin.isAfter(DateTime.now())) {
          // Calcular gastos para esta categoría
          double gastadoEnCategoria = 0;
          for (var transaccion in transacciones) {
            if (transaccion.tipoTransaccion == TipoTransacciones.GASTO &&
                transaccion.categoria == presupuesto.categoria) {
              gastadoEnCategoria += transaccion.cantidad;
            }
          }

          // Crear una nueva instancia de Presupuesto con el gasto calculado
          // usando el método actualizarConTransaccion para calcular la diferencia
          double diferenciaGasto =
              gastadoEnCategoria - presupuesto.cantidadGastada;
          if (diferenciaGasto != 0) {
            presupuestosActivos
                .add(presupuesto.actualizarConTransaccion(diferenciaGasto));
          } else {
            presupuestosActivos.add(presupuesto);
          }
        }
      }

      // Obtener metas de ahorro no completadas
      final metasAhorro = await _metasAhorroService.obtenerMetasAhorro(userId);
      final metasNoCompletadas =
          metasAhorro.where((m) => !m.completada).toList();

      // Ordenar transacciones por fecha (recientes primero) y limitar a 5
      transacciones
          .sort((a, b) => b.fechaTransaccion.compareTo(a.fechaTransaccion));
      final ultimasTransacciones = transacciones.take(5).toList();

      _ultimasTransacciones = ultimasTransacciones;
      _presupuestos = presupuestosActivos;
      _metasAhorro = metasNoCompletadas;
      _ingresosTotal = ingresos;
      _gastosTotal = gastos;
      _balanceTotal = ingresos - gastos;
      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar los datos: $e');
      _setLoading(false);
    }

    notifyListeners();
  }

  Future<void> cambiarMesAnterior() async {
    final mesAnterior = DateTime(_fechaInicio.year, _fechaInicio.month - 1, 1);
    final finMesAnterior = DateTime(_fechaInicio.year, _fechaInicio.month, 0);
    actualizarRangoFechas(mesAnterior, finMesAnterior);
  }

  Future<void> cambiarMesSiguiente() async {
    final mesSiguiente = DateTime(_fechaInicio.year, _fechaInicio.month + 1, 1);
    final finMesSiguiente =
        DateTime(_fechaInicio.year, _fechaInicio.month + 2, 0);
    actualizarRangoFechas(mesSiguiente, finMesSiguiente);
  }

  Future<void> cambiarMesActual() async {
    final DateTime ahora = DateTime.now();
    final mesActual = DateTime(ahora.year, ahora.month, 1);
    final finMesActual = DateTime(ahora.year, ahora.month + 1, 0);
    actualizarRangoFechas(mesActual, finMesActual);
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String message) {
    _errorMessage = message;
  }
}
