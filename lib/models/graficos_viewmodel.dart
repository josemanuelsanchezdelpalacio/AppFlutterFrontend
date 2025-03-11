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

  //variables para analisis de tendencias
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

  //variables para presupuesto
  double _presupuestoTotal = 0;
  double _presupuestoRestante = 0;
  Map<String, double> _presupuestosPorCategoria = {};
  Map<String, double> _gastosPorCategoria = {};
  Map<String, double> _utilizacionPorCategoria = {};

  List<PresupuestoCategoriaData> _categoriasPresupuesto = [];
  List<PresupuestoCategoriaData> _categoriasPrincipales = [];
  PresupuestoCategoriaData? _categoriaOtros;

  GraficosViewModel() {
    _transaccionesService = TransaccionesService();
  }

  //getters basicos
  bool get isLoading => _isLoading;
  double get ingresosTotales => _ingresosTotales;
  double get gastosTotales => _gastosTotales;
  double get ahorroTotal => _ahorroTotal;
  double get utilizacionPresupuesto => _utilizacionPresupuesto;
  double get porcentajeAhorro => _porcentajeAhorro;
  double get porcentajeGastos => _porcentajeGastos;
  List<Transaccion> get transacciones => _transacciones;
  List<Presupuesto> get presupuestos => _presupuestos;

  //getters para tenedencias
  Map<String, double> get ingresosMensuales => _ingresosMensuales;
  Map<String, double> get gastosMensuales => _gastosMensuales;
  Map<String, double> get ahorroMensual => _ahorroMensual;
  List<String> get mesesOrdenados => _mesesOrdenados;
  double get tendenciaIngresos => _tendenciaIngresos;
  double get tendenciaGastos => _tendenciaGastos;
  double get tendenciaAhorro => _tendenciaAhorro;

  //getters para presupuestos
  double get presupuestoTotal => _presupuestoTotal;
  double get presupuestoRestante => _presupuestoRestante;
  Map<String, double> get presupuestosPorCategoria => _presupuestosPorCategoria;
  Map<String, double> get gastosPorCategoria => _gastosPorCategoria;
  Map<String, double> get utilizacionPorCategoria => _utilizacionPorCategoria;

  //getters categorias agrupadas
  List<PresupuestoCategoriaData> get categoriasPresupuesto =>
      _categoriasPresupuesto;
  List<PresupuestoCategoriaData> get categoriasPrincipales =>
      _categoriasPrincipales;
  PresupuestoCategoriaData? get categoriaOtros => _categoriaOtros;

  Future<void> cargarDatos(int idUsuario) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _cargarTransacciones(idUsuario),
        _cargarPresupuestos(idUsuario),
      ]);

      // Si no hay presupuestos, añadimos uno predeterminado
      if (_presupuestos.isEmpty) {
        final DateTime hoy = DateTime.now();

        // Crear fechas para el presupuesto por defecto
        final DateTime inicioMes = DateTime(hoy.year, hoy.month, 1);
        final DateTime finMes = DateTime(hoy.year, hoy.month + 1, 0);

        _presupuestos.add(Presupuesto(
          id: -1,
          nombre: 'Presupuesto General',
          categoria: 'General',
          cantidad: 1000,
          fechaInicio: inicioMes,
          fechaFin: finMes,
          cantidadGastada: 0,
          cantidadRestante: 1000,
        ));
      }

      _calcularTotales();
      _calcularTendencias();
      _calcularDatosPresupuesto();
      _procesarCategorias();
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
      //oreno transacciones por fecha
      _transacciones
          .sort((a, b) => a.fechaTransaccion.compareTo(b.fechaTransaccion));
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

    //calculo porcentajes de ahorro y gastos
    if (_ingresosTotales > 0) {
      _porcentajeAhorro = (_ahorroTotal / _ingresosTotales) * 100;
      _porcentajeGastos = (_gastosTotales / _ingresosTotales) * 100;
    } else {
      _porcentajeAhorro = 0;
      _porcentajeGastos = 0;
    }

    if (_presupuestos.isNotEmpty) {
      _presupuestoTotal = _presupuestos.fold(0.0, (sum, p) => sum + p.cantidad);
      _utilizacionPresupuesto = _presupuestoTotal > 0
          ? (_gastosTotales / _presupuestoTotal) * 100
          : 0;
      _presupuestoRestante =
          _presupuestos.fold(0.0, (sum, p) => sum + p.cantidadRestante);
    } else {
      _utilizacionPresupuesto = 0;
      _presupuestoTotal = 0;
      _presupuestoRestante = 0;
    }
  }

  void _calcularTendencias() {
    //limpio datos anteriores
    _ingresosMensuales = {};
    _gastosMensuales = {};
    _ahorroMensual = {};

    //agrupo transacciones por mes
    for (var t in _transacciones) {
      final mesKey = DateFormat('MMM yy').format(t.fechaTransaccion);

      if (t.tipoTransaccion == TipoTransacciones.INGRESO) {
        _ingresosMensuales[mesKey] =
            (_ingresosMensuales[mesKey] ?? 0) + t.cantidad;
      } else {
        _gastosMensuales[mesKey] = (_gastosMensuales[mesKey] ?? 0) + t.cantidad;
      }
    }

    //ordeno los meses
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

    //calculo ahorro mensual
    for (String mes in _mesesOrdenados) {
      final ingresos = _ingresosMensuales[mes] ?? 0;
      final gastos = _gastosMensuales[mes] ?? 0;
      _ahorroMensual[mes] = ingresos - gastos;
    }

    //calculo tendencias usando los datos disponibles
    if (_mesesOrdenados.length >= 2) {
      final primerMes = _mesesOrdenados.first;
      final ultimoMes = _mesesOrdenados.last;

      final primerIngresos = _ingresosMensuales[primerMes] ?? 0;
      final ultimoIngresos = _ingresosMensuales[ultimoMes] ?? 0;

      final primerGastos = _gastosMensuales[primerMes] ?? 0;
      final ultimoGastos = _gastosMensuales[ultimoMes] ?? 0;

      final primerAhorro = _ahorroMensual[primerMes] ?? 0;
      final ultimoAhorro = _ahorroMensual[ultimoMes] ?? 0;

      //calculo la variacion porcentual
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

    //agrupo presupuestos por categoria
    for (var p in _presupuestos) {
      _presupuestosPorCategoria[p.categoria] =
          (_presupuestosPorCategoria[p.categoria] ?? 0) + p.cantidad;
    }

    //encuentro transacciones aplicables a cada presupuesto y asignar gastos
    for (var t in _transacciones) {
      if (t.tipoTransaccion != TipoTransacciones.INGRESO) {
        //compruebo que presupuestos aplican a esta transaccion
        bool asignado = false;

        for (var p in _presupuestos) {
          if (p.categoria == t.categoria &&
              p.isTransactionApplicable(t.fechaTransaccion)) {
            _gastosPorCategoria[p.categoria] =
                (_gastosPorCategoria[p.categoria] ?? 0) + t.cantidad;
            asignado = true;
            break;
          }
        }

        //si no se encontro un presupuesto especifico asigno el general'
        if (!asignado) {
          _gastosPorCategoria['General'] =
              (_gastosPorCategoria['General'] ?? 0) + t.cantidad;
        }
      }
    }

    //calculo utilizacion por categoria
    for (var categoria in {
      ..._presupuestosPorCategoria.keys,
      ..._gastosPorCategoria.keys
    }) {
      final presupuesto = _presupuestosPorCategoria[categoria] ?? 0;
      final gasto = _gastosPorCategoria[categoria] ?? 0;

      if (presupuesto > 0) {
        _utilizacionPorCategoria[categoria] = (gasto / presupuesto) * 100;
      } else {
        _utilizacionPorCategoria[categoria] = gasto > 0 ? 100 : 0;
      }
    }
  }

  //metodo para procesar categorias y crear objetos con datos completos
  void _procesarCategorias() {
    _categoriasPresupuesto = [];

    //creo una lista de objetos de categoria con todos los datos
    for (var categoria in {
      ..._presupuestosPorCategoria.keys,
      ..._gastosPorCategoria.keys
    }) {
      final presupuesto = _presupuestosPorCategoria[categoria] ?? 0;
      final gasto = _gastosPorCategoria[categoria] ?? 0;
      final utilizacion = _utilizacionPorCategoria[categoria] ?? 0;

      _categoriasPresupuesto.add(PresupuestoCategoriaData(
        nombre: categoria,
        presupuesto: presupuesto,
        gastoActual: gasto,
        porcentajeUtilizacion: utilizacion,
        restante: presupuesto - gasto,
      ));
    }

    //ordeno categorias por porcentaje de utilizacion (de mayor a menor)
    _categoriasPresupuesto.sort(
        (a, b) => b.porcentajeUtilizacion.compareTo(a.porcentajeUtilizacion));

    //separo las categorias principales y el resto
    if (_categoriasPresupuesto.length <= 5) {
      _categoriasPrincipales = List.from(_categoriasPresupuesto);
      _categoriaOtros = null;
    } else {
      //tomo las 4 categorias principales
      _categoriasPrincipales = _categoriasPresupuesto.take(4).toList();

      //agrupo el resto en otros
      final otrasCategoriasLista = _categoriasPresupuesto.skip(4).toList();

      double otrosPresupuesto = 0;
      double otrosGasto = 0;

      for (var cat in otrasCategoriasLista) {
        otrosPresupuesto += cat.presupuesto;
        otrosGasto += cat.gastoActual;
      }

      double otrosUtilizacion = otrosPresupuesto > 0
          ? (otrosGasto / otrosPresupuesto) * 100
          : otrosGasto > 0
              ? 100
              : 0;

      _categoriaOtros = PresupuestoCategoriaData(
        nombre: 'Otros',
        presupuesto: otrosPresupuesto,
        gastoActual: otrosGasto,
        porcentajeUtilizacion: otrosUtilizacion,
        restante: otrosPresupuesto - otrosGasto,
        incluyeCategorias: otrasCategoriasLista.map((e) => e.nombre).toList(),
      );
    }
  }

  //obtengo las principales categorias de gasto
  List<MapEntry<String, double>> obtenerPrincipalesGastos(int limit) {
    final gastosPorCategoria = Map.fromEntries(_transacciones
        .where((t) => t.tipoTransaccion != TipoTransacciones.INGRESO)
        .fold<Map<String, double>>({}, (map, t) {
          map[t.categoria] = (map[t.categoria] ?? 0) + t.cantidad;
          return map;
        })
        .entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value)));

    final entradas = gastosPorCategoria.entries.toList();
    return entradas
        .take(limit < entradas.length ? limit : entradas.length)
        .toList();
  }

  //obtengo los datos para el grafico de ingresos vs gastos mensuales
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

  //obtengo datos para el grafico de utilizacion del presupuesto
  List<PresupuestoChartData> obtenerDatosUtilizacionPresupuesto() {
    List<PresupuestoChartData> datos = [];

    //añado datos de utilizacion
    if (_presupuestoTotal > 0) {
      datos.add(PresupuestoChartData(
        //parte utilizada
          'Utilizado',
          _gastosTotales,
          _gastosTotales <= _presupuestoTotal
              ? Colors.orange
              : Colors.red
          ));

      //parte no utilizada (solo si no excede el presupuesto)
      if (_gastosTotales < _presupuestoTotal) {
        datos.add(PresupuestoChartData(
            'Disponible', _presupuestoRestante, Colors.green));
      }
    } else {
      //si no hay presupuesto muestro un valor por defecto
      datos.add(PresupuestoChartData('Sin presupuesto', 1, Colors.grey));
    }

    return datos;
  }

  //obtengo el color segun el nivel de utilizacion
  Color obtenerColorPorUtilizacion(double porcentaje) {
    if (porcentaje > 100) return Colors.red;
    if (porcentaje > 80) return Colors.orange;
    if (porcentaje > 60) return Colors.amber;
    if (porcentaje > 40) return Colors.yellow;
    return Colors.green;
  }

  //obtengo mensaje segun utilizacion
  String obtenerMensajeEstatus(double porcentaje) {
    if (porcentaje > 100) return 'Presupuesto excedido';
    if (porcentaje > 80) return 'Presupuesto casi agotado';
    if (porcentaje > 60) return 'Nivel de uso moderado';
    if (porcentaje > 40) return 'Uso razonable';
    return 'Presupuesto ampliamente disponible';
  }
}

//clase para representar datos de categoría de presupuesto
class PresupuestoCategoriaData {
  final String nombre;
  final double presupuesto;
  final double gastoActual;
  final double porcentajeUtilizacion;
  final double restante;
  final List<String>? incluyeCategorias;

  PresupuestoCategoriaData({
    required this.nombre,
    required this.presupuesto,
    required this.gastoActual,
    required this.porcentajeUtilizacion,
    required this.restante,
    this.incluyeCategorias,
  });
}

//clase para datos del grafico de presupuesto
class PresupuestoChartData {
  final String nombre;
  final double valor;
  final Color color;

  PresupuestoChartData(this.nombre, this.valor, this.color);
}


