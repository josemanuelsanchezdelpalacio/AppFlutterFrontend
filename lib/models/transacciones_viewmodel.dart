import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:intl/intl.dart';

class TransaccionesViewmodel extends ChangeNotifier {
  final int idUsuario;
  final TransaccionesService _transaccionesService = TransaccionesService();

  List<Transaccion> _transacciones = [];
  bool _isLoading = false;
  String? _filtroActual;
  DateTime? _fechaFiltro;
  DateTime? _mesFiltro;
  String _terminoBusqueda = '';
  bool _modoSeleccion = false;
  final Set<int> _transaccionesSeleccionadas = {};

  //lista de meses disponibles para filtrar
  List<String?> _mesesDisponibles = [null]; //null representa todos los meses

  TransaccionesViewmodel({required this.idUsuario});

  //getters
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get modoSeleccion => _modoSeleccion;
  set modoSeleccion(bool value) {
    _modoSeleccion = value;
    notifyListeners();
  }

  String? get filtroActual => _filtroActual;
  DateTime? get fechaFiltro => _fechaFiltro;
  DateTime? get mesFiltro => _mesFiltro;
  List<String?> get mesesDisponibles => _mesesDisponibles;
  Set<int> get transaccionesSeleccionadas => _transaccionesSeleccionadas;
  List<Transaccion> get transacciones => _transacciones;
  set transacciones(List<Transaccion> value) {
    _transacciones = value;
    notifyListeners();
  }

  //lista de opciones para filtrar
  List<String?> get opcionesFiltro => [null, 'Ingresos', 'Gastos'];

  //metodo para cargar transacciones
  Future<void> cargarTransacciones() async {
    try {
      //indico que la carga esta en progreso
      isLoading = true;

      //obtengo todas las transacciones
      List<Transaccion> listaTransacciones =
          await _transaccionesService.obtenerTransacciones(idUsuario);

      //ordoeno por fecha (mas recientes primero)
      listaTransacciones
          .sort((a, b) => b.fechaTransaccion.compareTo(a.fechaTransaccion));

      //actualizo la lista de transacciones
      transacciones = listaTransacciones;

      //actualizo la lista de meses disponibles
      _actualizarMesesDisponibles();

      //gestiono la seleccion multiple
      _gestionarSeleccionMultiple();

      isLoading = false;
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  //metodo para actualizar la lista de meses disponibles
  void _actualizarMesesDisponibles() {
    Set<String> mesesUnicos = {};

    for (var transaccion in _transacciones) {
      String mes =
          DateFormat('MMMM yyyy', 'es').format(transaccion.fechaTransaccion);
      mesesUnicos.add(mes);
    }

    //convierto a lista y ordeno cronologicamente
    List<String> mesesOrdenados = mesesUnicos.toList()
      ..sort((a, b) {
        try {
          DateTime fechaA = DateFormat('MMMM yyyy', 'es').parse(a);
          DateTime fechaB = DateFormat('MMMM yyyy', 'es').parse(b);
          return fechaB
              .compareTo(fechaA); // Orden inverso (más reciente primero)
        } catch (e) {
          return a.compareTo(b);
        }
      });

    //actualizo la lista de meses con todos los meses como primera opcion
    _mesesDisponibles = [null, ...mesesOrdenados];
  }

  //metodo para aplicar filtro
  void aplicarFiltro(String? filtro) {
    _filtroActual = filtro;
    notifyListeners();
  }

  //metodo para aplicar filtro de fecha
  void aplicarFiltroFecha(DateTime? fecha) {
    _fechaFiltro = fecha;
    notifyListeners();
  }

  //metodo para aplicar filtro de mes
  void aplicarFiltroMes(DateTime? mes) {
    _mesFiltro = mes;
    notifyListeners();
  }

  //metodo para aplicar busqueda
  void aplicarBusqueda(String termino) {
    _terminoBusqueda = termino.trim().toLowerCase();
    notifyListeners();
  }

  //metodo para verificar si una transaccion pertenece al mes seleccionado
  bool _transaccionEnMes(Transaccion transaccion, DateTime mes) {
    return transaccion.fechaTransaccion.year == mes.year &&
        transaccion.fechaTransaccion.month == mes.month;
  }

  //metodo para obtener transacciones filtradas
  List<Transaccion> get transaccionesFiltradas {
    List<Transaccion> resultado = List.from(_transacciones);

    //filtrar por tipo (ingreso/gasto)
    if (_filtroActual != null) {
      if (_filtroActual == 'Ingresos') {
        resultado = resultado
            .where((t) => t.tipoTransaccion == TipoTransacciones.INGRESO)
            .toList();
      } else if (_filtroActual == 'Gastos') {
        resultado = resultado
            .where((t) => t.tipoTransaccion == TipoTransacciones.GASTO)
            .toList();
      }
    }

    //para filtrar por fecha especifica
    if (_fechaFiltro != null) {
      resultado = resultado.where((t) {
        return t.fechaTransaccion.year == _fechaFiltro!.year &&
            t.fechaTransaccion.month == _fechaFiltro!.month &&
            t.fechaTransaccion.day == _fechaFiltro!.day;
      }).toList();
    }

    //para filtrar por mes
    if (_mesFiltro != null) {
      resultado =
          resultado.where((t) => _transaccionEnMes(t, _mesFiltro!)).toList();
    }

    //para filtrar por temino de busqueda
    if (_terminoBusqueda.isNotEmpty) {
      resultado = resultado.where((t) {
        return t.descripcion.toLowerCase().contains(_terminoBusqueda) ||
            t.categoria.toLowerCase().contains(_terminoBusqueda) ||
            t.cantidad.toString().contains(_terminoBusqueda);
      }).toList();
    }

    //ordeno por fecha (mas reciente primero)
    resultado.sort((a, b) => b.fechaTransaccion.compareTo(a.fechaTransaccion));

    return resultado;
  }

  //calculo de balance
  double get totalIngresos {
    return _transacciones
        .where((t) => t.tipoTransaccion == TipoTransacciones.INGRESO)
        .fold(0.0, (sum, t) => sum + t.cantidad);
  }

  double get totalGastos {
    return _transacciones
        .where((t) => t.tipoTransaccion == TipoTransacciones.GASTO)
        .fold(0.0, (sum, t) => sum + t.cantidad);
  }

  double get balance {
    return totalIngresos - totalGastos;
  }

  //formateo de moneda segun la configuración regional
  String formatoMoneda(double cantidad) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return formatoMoneda.format(cantidad);
  }

  //gestiono la seleccion multiple durante la carga de transacciones
  void _gestionarSeleccionMultiple() {
    //restauro la seleccion multiple si no hay elementos seleccionados
    if (transaccionesSeleccionadas.isEmpty) {
      modoSeleccion = false;
    } else {
      //filtro las selecciones para incluir solo IDs que siguen existiendo
      _transaccionesSeleccionadas
          .removeWhere((id) => !transacciones.any((t) => t.id == id));
    }
  }

  //metodo para eliminar una transaccion individual
  Future<void> eliminarTransaccion(int id) async {
    try {
      await _transaccionesService.eliminarTransaccion(idUsuario, id);
      await cargarTransacciones();
    } catch (e) {
      rethrow;
    }
  }

  //metodo para eliminar multiples transacciones seleccionadas
  Future<void> eliminarTransaccionesSeleccionadas() async {
    try {
      isLoading = true;

      //elimino cada transaccion seleccionada
      for (int id in transaccionesSeleccionadas) {
        await _transaccionesService.eliminarTransaccion(idUsuario, id);
      }

      //limpio la seleccion y desactivo modo seleccion
      transaccionesSeleccionadas.clear();
      modoSeleccion = false;

      //recargo la lista de transacciones
      await cargarTransacciones();
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  //alterno el modo de seleccion multiple
  void toggleModoSeleccion() {
    modoSeleccion = !modoSeleccion;
    if (!modoSeleccion) {
      transaccionesSeleccionadas.clear();
    }
    notifyListeners();
  }

  //alterno la seleccion de una transacción especifica
  void toggleSeleccionTransaccion(int? id) {
    if (id == null) return;

    if (transaccionesSeleccionadas.contains(id)) {
      transaccionesSeleccionadas.remove(id);
      if (transaccionesSeleccionadas.isEmpty) {
        modoSeleccion = false;
      }
    } else {
      transaccionesSeleccionadas.add(id);
    }
    notifyListeners();
  }

  //compruebo si una transaccion esta seleccionada
  bool isTransaccionSeleccionada(int? id) {
    if (id == null) return false;
    return transaccionesSeleccionadas.contains(id);
  }

  //selecciono todas las transacciones
  void seleccionarTodas() {
    transaccionesSeleccionadas.clear();
    transaccionesSeleccionadas
        .addAll(transacciones.where((t) => t.id != null).map((t) => t.id!));
    notifyListeners();
  }

  //deselecciono todas las transacciones
  void deseleccionarTodas() {
    transaccionesSeleccionadas.clear();
    modoSeleccion = false;
    notifyListeners();
  }

  //obtengo el icono correspondiente a una categoria
  IconData getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'alimentación':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'vivienda':
        return Icons.home;
      case 'entretenimiento':
        return Icons.movie;
      case 'salud':
        return Icons.healing;
      case 'educación':
        return Icons.school;
      case 'ropa':
        return Icons.shopping_bag;
      case 'servicios':
        return Icons.power;
      default:
        return Icons.category;
    }
  }
}


