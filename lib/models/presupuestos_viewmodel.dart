import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';

class PresupuestosViewModel extends ChangeNotifier {
  final int userId;
  final PresupuestosService _service = PresupuestosService();

  List<Presupuesto> _presupuestos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Presupuesto> get presupuestos => _presupuestos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters for summary statistics
  int get presupuestosSuperados => 
    _presupuestos.where((p) => estaSuperado(p)).length;

  int get presupuestosEnCurso => 
    _presupuestos.where((p) => !estaSuperado(p) && !estaVencido(p)).length;

  PresupuestosViewModel(this.userId);

  Future<void> cargarPresupuestos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _presupuestos = await _service.obtenerPresupuestos(userId);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron cargar los presupuestos. ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> eliminarPresupuesto(int presupuestoId) async {
    try {
      await _service.eliminarPresupuesto(userId, presupuestoId);
      _presupuestos.removeWhere((p) => p.id == presupuestoId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al eliminar el presupuesto: ${e.toString()}';
      notifyListeners();
    }
  }

  // Método para calcular el progreso de un presupuesto
  double calcularProgreso(Presupuesto presupuesto) {
    if (presupuesto.cantidad == 0) return 0.0;
    return (presupuesto.cantidadGastada) / presupuesto.cantidad;
  }

  // Método para verificar si el presupuesto está vencido
  bool estaVencido(Presupuesto presupuesto) {
    return DateTime.now().isAfter(presupuesto.fechaFin);
  }

  // Método para verificar si el presupuesto ha sido superado
  bool estaSuperado(Presupuesto presupuesto) {
    return (presupuesto.cantidadGastada) > presupuesto.cantidad;
  }

  // Método para obtener ícono de categoría
  IconData obtenerIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'salario':
        return Icons.attach_money;
      case 'inversiones':
        return Icons.trending_up;
      case 'freelance':
        return Icons.computer;
      case 'regalo':
        return Icons.card_giftcard;
      case 'reembolso':
        return Icons.monetization_on;
      case 'venta':
        return Icons.store;
      case 'otros':
        return Icons.category;
      default:
        return Icons.money;
    }
  }
}


