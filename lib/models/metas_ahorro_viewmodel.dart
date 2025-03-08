import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';

class MetasAhorroViewModel extends ChangeNotifier {
  final int userId;
  final MetasAhorroService _metasAhorroService = MetasAhorroService();

  bool _isLoading = false;
  List<MetaAhorro> _metasAhorro = [];
  String? _errorMessage;

  MetasAhorroViewModel(this.userId);

  // Getters
  bool get isLoading => _isLoading;
  List<MetaAhorro> get metasAhorro => _metasAhorro;
  String? get errorMessage => _errorMessage;

  int get metasCompletadas =>
      _metasAhorro.where((meta) => meta.completada).length;
  int get metasPendientes =>
      _metasAhorro.where((meta) => !meta.completada).length;

  // Métodos
  Future<void> cargarMetasAhorro() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final metas = await _metasAhorroService.obtenerMetasAhorro(userId);
      _metasAhorro = metas;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar las metas de ahorro: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarMetaAhorro(int metaId) async {
    try {
      await _metasAhorroService.eliminarMetaAhorro(userId, metaId);
      await cargarMetasAhorro();
    } catch (e) {
      throw Exception('Error al eliminar la meta de ahorro: $e');
    }
  }

  // Métodos de cálculo y utilidad
  double calcularProgreso(MetaAhorro meta) {
    double progreso = meta.cantidadActual / meta.cantidadObjetivo;
    if (progreso > 1) progreso = 1;
    return progreso;
  }

  bool estaVencida(MetaAhorro meta) {
    return diasRestantes(meta) < 0 && !meta.completada;
  }

  int diasRestantes(MetaAhorro meta) {
    return meta.fechaObjetivo.difference(DateTime.now()).inDays;
  }

  double calcularCantidadRestante(MetaAhorro meta) {
    double restante = meta.cantidadObjetivo - meta.cantidadActual;
    return restante > 0 ? restante : 0;
  }

  String obtenerTextoTiempoRestante(MetaAhorro meta) {
    final dias = diasRestantes(meta);
    if (dias > 0) {
      return '$dias días restantes';
    } else if (dias == 0) {
      return 'Vence hoy';
    } else {
      return 'Vencida hace ${-dias} días';
    }
  }

  IconData obtenerIconoCategoria(String categoria) {
    switch (categoria) {
      case 'Salario':
        return Icons.payments;
      case 'Inversiones':
        return Icons.trending_up;
      case 'Freelance':
        return Icons.work;
      case 'Regalo':
        return Icons.card_giftcard;
      case 'Reembolso':
        return Icons.assignment_return;
      case 'Venta':
        return Icons.store;
      case 'Otros':
        return Icons.more_horiz;
      default:
        return Icons.savings;
    }
  }
}

