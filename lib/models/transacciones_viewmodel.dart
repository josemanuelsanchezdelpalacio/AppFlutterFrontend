import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:intl/intl.dart';

class TransaccionesViewModel extends ChangeNotifier {
  final int idUsuario;
  final TransaccionesService _service = TransaccionesService();

  List<Transaccion> _transacciones = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _filtroActual;
  DateTime? _fechaFiltro;
  DateTime? _mesFiltro;
  String _terminoBusqueda = '';
  bool _modoSeleccion = false;
  final Set<int> _transaccionesSeleccionadas = {};
  List<String?> _mesesDisponibles = [null];

  TransaccionesViewModel({required this.idUsuario});

  // Getters
  bool get isLoading => _isLoading;
  bool get modoSeleccion => _modoSeleccion;
  List<Transaccion> get transacciones => _transacciones;
  List<Transaccion> get transaccionesFiltradas => _obtenerTransaccionesFiltradas();
  Set<int> get transaccionesSeleccionadas => _transaccionesSeleccionadas;
  String? get filtroActual => _filtroActual;
  DateTime? get fechaFiltro => _fechaFiltro;
  DateTime? get mesFiltro => _mesFiltro;
  List<String?> get mesesDisponibles => _mesesDisponibles;
  String? get errorMessage => _errorMessage;

  // Cálculos financieros
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
      rethrow;
    }
  }

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
      rethrow;
    }
  }

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
    }
    notifyListeners();
  }

  void toggleSeleccionTransaccion(int? id) {
    if (id == null) return;

    if (_transaccionesSeleccionadas.contains(id)) {
      _transaccionesSeleccionadas.remove(id);
    } else {
      _transaccionesSeleccionadas.add(id);
    }

    if (_transaccionesSeleccionadas.isEmpty) {
      _modoSeleccion = false;
    }
    notifyListeners();
  }

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

  String formatoMoneda(double cantidad) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return formatoMoneda.format(cantidad);
  }
}

