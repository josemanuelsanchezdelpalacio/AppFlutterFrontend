import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:intl/intl.dart';

class GraficosViewModel extends ChangeNotifier {
  final PresupuestosService _presupuestosService = PresupuestosService();
  late final TransaccionesService _transaccionesService;

  List<Transaccion> _transacciones = [];
  List<Presupuesto> _presupuestos = [];
  
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
  double _utilizacionPresupuesto = 0;
  double _porcentajeAhorro = 0;
  double _porcentajeGastos = 0;
  
  // Variables para presupuesto
  double _presupuestoTotal = 0;
  double _presupuestoRestante = 0;
  Map<String, double> _presupuestosPorCategoria = {};
  Map<String, double> _gastosPorCategoria = {};
  Map<String, double> _utilizacionPorCategoria = {};

  GraficosViewModel() {
    _transaccionesService = TransaccionesService();
  }

  // Getters básicos
  bool get isLoading => _isLoading;
  double get ingresosTotales => _ingresosTotales;
  double get gastosTotales => _gastosTotales;
  double get ahorroTotal => _ahorroTotal;
  double get utilizacionPresupuesto => _utilizacionPresupuesto;
  double get porcentajeAhorro => _porcentajeAhorro;
  double get porcentajeGastos => _porcentajeGastos;
  List<Transaccion> get transacciones => _transacciones;
  List<Presupuesto> get presupuestos => _presupuestos;
  
  // Getters para tendencias
  Map<String, double> get ingresosMensuales => _ingresosMensuales;
  Map<String, double> get gastosMensuales => _gastosMensuales;
  Map<String, double> get ahorroMensual => _ahorroMensual;
  List<String> get mesesOrdenados => _mesesOrdenados;
  double get tendenciaIngresos => _tendenciaIngresos;
  double get tendenciaGastos => _tendenciaGastos;
  double get tendenciaAhorro => _tendenciaAhorro;
  
  // Getters para presupuesto
  double get presupuestoTotal => _presupuestoTotal;
  double get presupuestoRestante => _presupuestoRestante;
  Map<String, double> get presupuestosPorCategoria => _presupuestosPorCategoria;
  Map<String, double> get gastosPorCategoria => _gastosPorCategoria;
  Map<String, double> get utilizacionPorCategoria => _utilizacionPorCategoria;

  Future<void> cargarDatos(int idUsuario) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _cargarTransacciones(idUsuario),
        _cargarPresupuestos(idUsuario),
      ]);
      _calcularTotales();
      _calcularTendencias();
      _calcularDatosPresupuesto();
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cargarTransacciones(int idUsuario) async {
    try {
      _transacciones = await _transaccionesService.obtenerTransacciones(idUsuario);
      // Ordenar transacciones por fecha
      _transacciones.sort((a, b) => a.fechaTransaccion.compareTo(b.fechaTransaccion));
    } catch (e) {
      print('Error al cargar transacciones: $e');
      _transacciones = [];
    }
  }

  Future<void> _cargarPresupuestos(int idUsuario) async {
    try {
      _presupuestos = await _presupuestosService.obtenerPresupuestos(idUsuario);
    } catch (e) {
      print('Error al cargar presupuestos: $e');
      _presupuestos = [];
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

    // Calcular porcentajes de ahorro y gastos
    if (_ingresosTotales > 0) {
      _porcentajeAhorro = (_ahorroTotal / _ingresosTotales) * 100;
      _porcentajeGastos = (_gastosTotales / _ingresosTotales) * 100;
    } else {
      _porcentajeAhorro = 0;
      _porcentajeGastos = 0;
    }

    if (_presupuestos.isNotEmpty) {
      _presupuestoTotal = _presupuestos.fold(0.0, (sum, p) => sum + p.cantidad);
      _utilizacionPresupuesto = _presupuestoTotal > 0 ? (_gastosTotales / _presupuestoTotal) * 100 : 0;
      _presupuestoRestante = _presupuestoTotal > _gastosTotales ? _presupuestoTotal - _gastosTotales : 0;
    } else {
      _utilizacionPresupuesto = 0;
      _presupuestoTotal = 0;
      _presupuestoRestante = 0;
    }
  }
  
  void _calcularTendencias() {
    // Limpiar datos anteriores
    _ingresosMensuales = {};
    _gastosMensuales = {};
    _ahorroMensual = {};
    
    // Agrupar transacciones por mes
    for (var t in _transacciones) {
      final mesKey = DateFormat('MMM yy').format(t.fechaTransaccion);
      
      if (t.tipoTransaccion == TipoTransacciones.INGRESO) {
        _ingresosMensuales[mesKey] = (_ingresosMensuales[mesKey] ?? 0) + t.cantidad;
      } else {
        _gastosMensuales[mesKey] = (_gastosMensuales[mesKey] ?? 0) + t.cantidad;
      }
    }
    
    // Ordenar los meses cronológicamente
    _mesesOrdenados = {..._ingresosMensuales.keys, ..._gastosMensuales.keys}.toList();
    _mesesOrdenados.sort((a, b) {
      try {
        final fechaA = DateFormat('MMM yy').parse(a);
        final fechaB = DateFormat('MMM yy').parse(b);
        return fechaA.compareTo(fechaB);
      } catch (_) {
        return a.compareTo(b);
      }
    });
    
    // Calcular ahorro mensual
    for (String mes in _mesesOrdenados) {
      final ingresos = _ingresosMensuales[mes] ?? 0;
      final gastos = _gastosMensuales[mes] ?? 0;
      _ahorroMensual[mes] = ingresos - gastos;
    }
    
    // Calcular tendencias usando los datos disponibles
    if (_mesesOrdenados.length >= 2) {
      final primerMes = _mesesOrdenados.first;
      final ultimoMes = _mesesOrdenados.last;
      
      final primerIngresos = _ingresosMensuales[primerMes] ?? 0;
      final ultimoIngresos = _ingresosMensuales[ultimoMes] ?? 0;
      
      final primerGastos = _gastosMensuales[primerMes] ?? 0;
      final ultimoGastos = _gastosMensuales[ultimoMes] ?? 0;
      
      final primerAhorro = _ahorroMensual[primerMes] ?? 0;
      final ultimoAhorro = _ahorroMensual[ultimoMes] ?? 0;
      
      // Calcular la variación porcentual
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
  
  void _calcularDatosPresupuesto() {
    _presupuestosPorCategoria = {};
    _gastosPorCategoria = {};
    _utilizacionPorCategoria = {};
    
    // Agrupar presupuestos por categoría
    for (var p in _presupuestos) {
      _presupuestosPorCategoria[p.categoria] = (_presupuestosPorCategoria[p.categoria] ?? 0) + p.cantidad;
    }
    
    // Agrupar gastos por categoría
    for (var t in _transacciones) {
      if (t.tipoTransaccion != TipoTransacciones.INGRESO) {
        _gastosPorCategoria[t.categoria] = (_gastosPorCategoria[t.categoria] ?? 0) + t.cantidad;
      }
    }
    
    // Calcular utilización por categoría
    for (var categoria in {..._presupuestosPorCategoria.keys, ..._gastosPorCategoria.keys}) {
      final presupuesto = _presupuestosPorCategoria[categoria] ?? 0;
      final gasto = _gastosPorCategoria[categoria] ?? 0;
      
      if (presupuesto > 0) {
        _utilizacionPorCategoria[categoria] = (gasto / presupuesto) * 100;
      } else {
        _utilizacionPorCategoria[categoria] = gasto > 0 ? 100 : 0;
      }
    }
  }
  
  // Obtener las principales categorías de gasto
  List<MapEntry<String, double>> obtenerPrincipalesGastos(int limit) {
    final gastosPorCategoria = Map.fromEntries(
      _transacciones
          .where((t) => t.tipoTransaccion != TipoTransacciones.INGRESO)
          .fold<Map<String, double>>({}, (map, t) {
        map[t.categoria] = (map[t.categoria] ?? 0) + t.cantidad;
        return map;
      }).entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    
    return gastosPorCategoria.entries.take(limit).toList();
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

