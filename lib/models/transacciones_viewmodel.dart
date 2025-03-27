import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:intl/intl.dart';

<<<<<<< HEAD
class TransaccionesViewModel extends ChangeNotifier {
  final int idUsuario;
  final TransaccionesService _service = TransaccionesService();

  List<Transaccion> _transacciones = [];
  bool _isLoading = false;
  String? _errorMessage;
=======
class TransaccionesViewmodel extends ChangeNotifier {
  final int idUsuario;
  final TransaccionesService _transaccionesService = TransaccionesService();

  List<Transaccion> _transacciones = [];
  bool _isLoading = false;
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  String? _filtroActual;
  DateTime? _fechaFiltro;
  DateTime? _mesFiltro;
  String _terminoBusqueda = '';
  bool _modoSeleccion = false;
  final Set<int> _transaccionesSeleccionadas = {};
<<<<<<< HEAD
  List<String?> _mesesDisponibles = [null];

  TransaccionesViewModel({required this.idUsuario});

  // Getters
  bool get isLoading => _isLoading;
  bool get modoSeleccion => _modoSeleccion;
  List<Transaccion> get transacciones => _transacciones;
  List<Transaccion> get transaccionesFiltradas => _obtenerTransaccionesFiltradas();
  Set<int> get transaccionesSeleccionadas => _transaccionesSeleccionadas;
=======

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

>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  String? get filtroActual => _filtroActual;
  DateTime? get fechaFiltro => _fechaFiltro;
  DateTime? get mesFiltro => _mesFiltro;
  List<String?> get mesesDisponibles => _mesesDisponibles;
<<<<<<< HEAD
  String? get errorMessage => _errorMessage;

  // Cálculos financieros
=======
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
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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

<<<<<<< HEAD
  double get balance => totalIngresos - totalGastos;

  // Método para cargar transacciones
  Future<void> cargarTransacciones() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transacciones = await _service.obtenerTransacciones(idUsuario);
      _actualizarMesesDisponibles();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar transacciones: ${e.toString()}';
    }
    notifyListeners();
  }

  // Método para eliminar transacción
  Future<void> eliminarTransaccion(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.eliminarTransaccion(idUsuario, id);
      await cargarTransacciones();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar transacción: ${e.toString()}';
      notifyListeners();
=======
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
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
      rethrow;
    }
  }

<<<<<<< HEAD
  // Método para eliminar múltiples transacciones
  Future<void> eliminarTransaccionesSeleccionadas() async {
    _isLoading = true;
    notifyListeners();

    try {
      for (int id in _transaccionesSeleccionadas) {
        await _service.eliminarTransaccion(idUsuario, id);
      }
      await cargarTransacciones();
      _transaccionesSeleccionadas.clear();
      _modoSeleccion = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar transacciones: ${e.toString()}';
      notifyListeners();
=======
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
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
      rethrow;
    }
  }

<<<<<<< HEAD
  // Métodos de selección múltiple
  void iniciarSeleccionMultiple() {
    _modoSeleccion = true;
    _transaccionesSeleccionadas.clear();
    notifyListeners();
  }

  // Métodos de selección
  void toggleSeleccionMultiple() {
    _modoSeleccion = !_modoSeleccion;
    if (!_modoSeleccion) {
      _transaccionesSeleccionadas.clear();
=======
  //alterno el modo de seleccion multiple
  void toggleModoSeleccion() {
    modoSeleccion = !modoSeleccion;
    if (!modoSeleccion) {
      transaccionesSeleccionadas.clear();
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    }
    notifyListeners();
  }

<<<<<<< HEAD
  void toggleSeleccionTransaccion(int? id) {
    if (id == null) return;

    if (_transaccionesSeleccionadas.contains(id)) {
      _transaccionesSeleccionadas.remove(id);
    } else {
      _transaccionesSeleccionadas.add(id);
    }

    if (_transaccionesSeleccionadas.isEmpty) {
      _modoSeleccion = false;
=======
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
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    }
    notifyListeners();
  }

<<<<<<< HEAD
  void seleccionarTodas() {
    _transaccionesSeleccionadas.clear();
    _transaccionesSeleccionadas.addAll(
      transaccionesFiltradas.where((t) => t.id != null).map((t) => t.id!)
    );
    _modoSeleccion = true;
    notifyListeners();
  }

  void deseleccionarTodas() {
    _transaccionesSeleccionadas.clear();
    _modoSeleccion = false;
    notifyListeners();
  }

  bool isTransaccionSeleccionada(int? id) {
    if (id == null) return false;
    return _transaccionesSeleccionadas.contains(id);
  }

  // Métodos de filtrado
  void aplicarFiltro(String? filtro) {
    _filtroActual = filtro;
    notifyListeners();
  }

  void aplicarFiltroFecha(DateTime? fecha) {
    _fechaFiltro = fecha;
    notifyListeners();
  }

  void aplicarFiltroMes(DateTime? mes) {
    _mesFiltro = mes;
    notifyListeners();
  }

  void aplicarBusqueda(String termino) {
    _terminoBusqueda = termino.trim().toLowerCase();
    notifyListeners();
  }

  // Métodos auxiliares
  List<Transaccion> _obtenerTransaccionesFiltradas() {
    List<Transaccion> resultado = List.from(_transacciones);

    // Filtrar por tipo
    if (_filtroActual != null) {
      resultado = resultado.where((t) {
        return _filtroActual == 'Ingresos' 
          ? t.tipoTransaccion == TipoTransacciones.INGRESO
          : t.tipoTransaccion == TipoTransacciones.GASTO;
      }).toList();
    }

    // Filtrar por fecha específica
    if (_fechaFiltro != null) {
      resultado = resultado.where((t) {
        return t.fechaTransaccion.year == _fechaFiltro!.year &&
               t.fechaTransaccion.month == _fechaFiltro!.month &&
               t.fechaTransaccion.day == _fechaFiltro!.day;
      }).toList();
    }

    // Filtrar por mes
    if (_mesFiltro != null) {
      resultado = resultado.where((t) {
        return t.fechaTransaccion.year == _mesFiltro!.year &&
               t.fechaTransaccion.month == _mesFiltro!.month;
      }).toList();
    }

    // Filtrar por búsqueda
    if (_terminoBusqueda.isNotEmpty) {
      resultado = resultado.where((t) {
        return t.descripcion.toLowerCase().contains(_terminoBusqueda) ||
               t.categoria.toLowerCase().contains(_terminoBusqueda) ||
               t.cantidad.toString().contains(_terminoBusqueda);
      }).toList();
    }

    // Ordenar por fecha (más recientes primero)
    resultado.sort((a, b) => b.fechaTransaccion.compareTo(a.fechaTransaccion));

    return resultado;
  }

  void _actualizarMesesDisponibles() {
    Set<String> mesesUnicos = {};

    for (var transaccion in _transacciones) {
      String mes = DateFormat('MMMM yyyy', 'es').format(transaccion.fechaTransaccion);
      mesesUnicos.add(mes);
    }

    List<String> mesesOrdenados = mesesUnicos.toList()
      ..sort((a, b) {
        try {
          DateTime fechaA = DateFormat('MMMM yyyy', 'es').parse(a);
          DateTime fechaB = DateFormat('MMMM yyyy', 'es').parse(b);
          return fechaB.compareTo(fechaA);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    _mesesDisponibles = [null, ...mesesOrdenados];
  }

=======
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
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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
<<<<<<< HEAD

  String formatoMoneda(double cantidad) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return formatoMoneda.format(cantidad);
  }
}

=======
}


>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
