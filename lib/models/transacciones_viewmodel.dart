import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:intl/intl.dart';

class TransaccionesViewmodel extends ChangeNotifier {
  final int idUsuario;
  final TransaccionesService _transaccionesService = TransaccionesService();
  
  // Lista de transacciones y estado de carga
  List<Transaccion> transacciones = [];
  bool isLoading = false;

  // Control para el modo de selección múltiple
  bool modoSeleccion = false;
  Set<int> transaccionesSeleccionadas = {};

  // Constructor
  TransaccionesViewmodel({required this.idUsuario});

  // Cálculo del balance total (ingresos - gastos)
  double get balance {
    return totalIngresos - totalGastos;
  }
  
  // Cálculo del total de ingresos
  double get totalIngresos {
    return transacciones
        .where((t) => t.tipoTransaccion == TipoTransacciones.INGRESO)
        .map((t) => t.cantidad)
        .fold(0, (a, b) => a + b);
  }
  
  // Cálculo del total de gastos
  double get totalGastos {
    return transacciones
        .where((t) => t.tipoTransaccion == TipoTransacciones.GASTO)
        .map((t) => t.cantidad)
        .fold(0, (a, b) => a + b);
  }

  // Formateo de moneda según la configuración regional
  String formatoMoneda(double cantidad) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return formatoMoneda.format(cantidad);
  }

  // Carga de transacciones
  Future<void> cargarTransacciones() async {
    try {
      // Indico que la carga está en progreso
      isLoading = true;
      notifyListeners();
      
      // Obtengo todas las transacciones
      List<Transaccion> listaTransacciones = 
          await _transaccionesService.obtenerTransacciones(idUsuario);
      
      // Ordeno por fecha (más recientes primero)
      listaTransacciones.sort((a, b) => 
          b.fechaTransaccion.compareTo(a.fechaTransaccion));
      
      // Actualizo la lista de transacciones
      transacciones = listaTransacciones;
      
      // Gestiono la selección múltiple
      _gestionarSeleccionMultiple();
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Gestiono la selección múltiple durante la carga de transacciones
  void _gestionarSeleccionMultiple() {
    // Restauro la selección múltiple si no hay elementos seleccionados
    if (transaccionesSeleccionadas.isEmpty) {
      modoSeleccion = false;
    } else {
      // Filtro las selecciones para incluir solo IDs que siguen existiendo
      transaccionesSeleccionadas = transaccionesSeleccionadas
          .where((id) => transacciones.any((t) => t.id == id))
          .toSet();
    }
  }

  // Método para eliminar una transacción individual
  Future<void> eliminarTransaccion(int id) async {
    try {
      await _transaccionesService.eliminarTransaccion(idUsuario, id);
      await cargarTransacciones();
    } catch (e) {
      rethrow;
    }
  }
  
  // Método para eliminar múltiples transacciones seleccionadas
  Future<void> eliminarTransaccionesSeleccionadas() async {
    try {
      isLoading = true;
      notifyListeners();
      
      // Elimino cada transacción seleccionada
      for (int id in transaccionesSeleccionadas) {
        await _transaccionesService.eliminarTransaccion(idUsuario, id);
      }
      
      // Limpio la selección y desactivo modo selección
      transaccionesSeleccionadas.clear();
      modoSeleccion = false;
      
      // Recargo la lista de transacciones
      await cargarTransacciones();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Alterno el modo de selección múltiple
  void toggleModoSeleccion() {
    modoSeleccion = !modoSeleccion;
    if (!modoSeleccion) {
      transaccionesSeleccionadas.clear();
    }
    notifyListeners();
  }
  
  // Alterno la selección de una transacción específica
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
  
  // Compruebo si una transacción está seleccionada
  bool isTransaccionSeleccionada(int? id) {
    if (id == null) return false;
    return transaccionesSeleccionadas.contains(id);
  }
  
  // Selecciono todas las transacciones
  void seleccionarTodas() {
    transaccionesSeleccionadas = transacciones
        .where((t) => t.id != null)
        .map((t) => t.id!)
        .toSet();
    notifyListeners();
  }
  
  // Deselecciono todas las transacciones
  void deseleccionarTodas() {
    transaccionesSeleccionadas.clear();
    modoSeleccion = false;
    notifyListeners();
  }

  // Obtengo el icono correspondiente a una categoría
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
