import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:intl/intl.dart';

// Clase para datos del gráfico accesible globalmente
class ChartData {
  final String categoria;
  final double cantidad;
  final Color color;

  ChartData(this.categoria, this.cantidad, this.color);
}

class GraficosViewModel extends ChangeNotifier {
  final TransaccionesService _transaccionesService;

  List<Transaccion> _transacciones = [];

  // Variables para análisis de tendencias
  Map<String, double> _ingresosMensuales = {};
  Map<String, double> _gastosMensuales = {};
  Map<String, double> _ahorroMensual = {};
  List<String> _mesesOrdenados = [];
  double _tendenciaIngresos = 0;
  double _tendenciaGastos = 0;
  double _tendenciaAhorro = 0;

  bool _isLoading = false;

  double _ingresosTotales = 0;
  double _gastosTotales = 0;
  double _ahorroTotal = 0;
  double _porcentajeAhorro = 0;
  double _porcentajeGastos = 0;
  double _porcentajeIngresos = 100; // Añadido porcentaje de ingresos

  GraficosViewModel({TransaccionesService? transaccionesService})
      : _transaccionesService = transaccionesService ?? TransaccionesService();

  // Getters básicos
  bool get isLoading => _isLoading;
  double get ingresosTotales => _ingresosTotales;
  double get gastosTotales => _gastosTotales;
  double get ahorroTotal => _ahorroTotal;
  double get porcentajeAhorro => _porcentajeAhorro;
  double get porcentajeGastos => _porcentajeGastos;
  double get porcentajeIngresos => _porcentajeIngresos; // Getter para porcentaje de ingresos
  List<Transaccion> get transacciones => _transacciones;

  // Getters para tendencias
  Map<String, double> get ingresosMensuales => _ingresosMensuales;
  Map<String, double> get gastosMensuales => _gastosMensuales;
  Map<String, double> get ahorroMensual => _ahorroMensual;
  List<String> get mesesOrdenados => _mesesOrdenados;
  double get tendenciaIngresos => _tendenciaIngresos;
  double get tendenciaGastos => _tendenciaGastos;
  double get tendenciaAhorro => _tendenciaAhorro;

  // Getter para utilizacionPresupuesto (eliminado de la UI pero mantenido para compatibilidad)
  double get utilizacionPresupuesto =>
      _gastosTotales > 0 ? (_gastosTotales / _ingresosTotales) * 100 : 0;

  Future<void> cargarDatos(int idUsuario) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cargarTransacciones(idUsuario);

      _calcularTotales();
      _calcularTendencias();
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cargarTransacciones(int idUsuario) async {
    try {
      _transacciones =
          await _transaccionesService.obtenerTransacciones(idUsuario);
      // Ordeno transacciones por fecha
      _transacciones
          .sort((a, b) => a.fechaTransaccion.compareTo(b.fechaTransaccion));
    } catch (e) {
      print('Error al cargar transacciones: $e');
      _transacciones = [];
    }
  }

  void _calcularTotales() {
    _ingresosTotales = _transacciones
        .where((t) => t.tipoTransaccion == TipoTransacciones.INGRESO)
        .fold(0.0, (sum, t) => sum + t.cantidad);

    _gastosTotales = _transacciones
        .where((t) => t.tipoTransaccion != TipoTransacciones.INGRESO)
        .fold(0.0, (sum, t) => sum + t.cantidad);

    _ahorroTotal = _ingresosTotales - _gastosTotales;

    // Cálculo porcentajes de ahorro, gastos e ingresos
    if (_ingresosTotales > 0) {
      _porcentajeAhorro = (_ahorroTotal / _ingresosTotales) * 100;
      _porcentajeGastos = (_gastosTotales / _ingresosTotales) * 100;
      _porcentajeIngresos = 100; // Los ingresos representan el 100% del total
    } else {
      _porcentajeAhorro = 0;
      _porcentajeGastos = 0;
      _porcentajeIngresos = 0;
    }
  }

  void _calcularTendencias() {
    // Limpio datos anteriores
    _ingresosMensuales = {};
    _gastosMensuales = {};
    _ahorroMensual = {};

    // Agrupo transacciones por mes
    for (var t in _transacciones) {
      final mesKey = DateFormat('MMM yy').format(t.fechaTransaccion);

      if (t.tipoTransaccion == TipoTransacciones.INGRESO) {
        _ingresosMensuales[mesKey] =
            (_ingresosMensuales[mesKey] ?? 0) + t.cantidad;
      } else {
        _gastosMensuales[mesKey] = (_gastosMensuales[mesKey] ?? 0) + t.cantidad;
      }
    }

    // Ordeno los meses
    _mesesOrdenados =
        {..._ingresosMensuales.keys, ..._gastosMensuales.keys}.toList();
    _mesesOrdenados.sort((a, b) {
      try {
        final fechaA = DateFormat('MMM yy').parse(a);
        final fechaB = DateFormat('MMM yy').parse(b);
        return fechaA.compareTo(fechaB);
      } catch (_) {
        return a.compareTo(b);
      }
    });

    // Calculo ahorro mensual
    for (String mes in _mesesOrdenados) {
      final ingresos = _ingresosMensuales[mes] ?? 0;
      final gastos = _gastosMensuales[mes] ?? 0;
      _ahorroMensual[mes] = ingresos - gastos;
    }

    // Cálculo tendencias usando los datos disponibles
    if (_mesesOrdenados.length >= 2) {
      final primerMes = _mesesOrdenados.first;
      final ultimoMes = _mesesOrdenados.last;

      final primerIngresos = _ingresosMensuales[primerMes] ?? 0;
      final ultimoIngresos = _ingresosMensuales[ultimoMes] ?? 0;

      final primerGastos = _gastosMensuales[primerMes] ?? 0;
      final ultimoGastos = _gastosMensuales[ultimoMes] ?? 0;

      final primerAhorro = _ahorroMensual[primerMes] ?? 0;
      final ultimoAhorro = _ahorroMensual[ultimoMes] ?? 0;

      // Cálculo la variación porcentual
      _tendenciaIngresos = primerIngresos > 0
          ? ((ultimoIngresos - primerIngresos) / primerIngresos) * 100
          : 0;

      _tendenciaGastos = primerGastos > 0
          ? ((ultimoGastos - primerGastos) / primerGastos) * 100
          : 0;

      _tendenciaAhorro = primerAhorro != 0
          ? ((ultimoAhorro - primerAhorro) / primerAhorro.abs()) * 100
          : 0;
    }
  }

  // Obtener las principales categorías de gasto
  List<MapEntry<String, double>> obtenerPrincipalesGastos(int limit) {
    // Create a Map of categories and their total amounts
    final gastosPorCategoria = _transacciones
        .where((t) => t.tipoTransaccion != TipoTransacciones.INGRESO)
        .fold<Map<String, double>>({}, (map, t) {
      map[t.categoria] = (map[t.categoria] ?? 0) + t.cantidad;
      return map;
    });

    // Convert to List of MapEntry objects and sort
    final gastosPorCategoriaList = gastosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Now take the top entries up to the limit
    return gastosPorCategoriaList
        .take(limit < gastosPorCategoriaList.length
            ? limit
            : gastosPorCategoriaList.length)
        .toList();
  }

  // Obtener datos para el gráfico de ingresos vs gastos mensuales
  List<Map<String, dynamic>> obtenerDatosIngresosGastosMensuales() {
    List<Map<String, dynamic>> datos = [];

    for (String mes in _mesesOrdenados) {
      datos.add({
        'mes': mes,
        'ingresos': _ingresosMensuales[mes] ?? 0,
        'gastos': _gastosMensuales[mes] ?? 0,
        'ahorro': _ahorroMensual[mes] ?? 0,
      });
    }

    return datos;
  }
}


