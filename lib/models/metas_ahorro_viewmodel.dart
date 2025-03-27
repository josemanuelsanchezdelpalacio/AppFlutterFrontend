import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';
import 'package:intl/intl.dart';

class MetasAhorroViewModel extends ChangeNotifier {
  final int userId;
  final MetasAhorroService _metasAhorroService = MetasAhorroService();

  bool _isLoading = false;
  List<MetaAhorro> _metasAhorro = [];
  String? _errorMessage;
  String? _filtroActual;
  DateTime? _mesFiltro;
  List<String?> _mesesDisponibles = [];

<<<<<<< HEAD
=======
  //lista de filtros disponibles
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  final List<String?> _filtros = [
    null, //sin filtro
    'Completadas',
    'Pendientes',
    'Vencidas',
    'Próximas a vencer'
  ];

  MetasAhorroViewModel(this.userId);

<<<<<<< HEAD
=======
  //getters
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  bool get isLoading => _isLoading;
  List<MetaAhorro> get metasAhorro => _metasAhorro;
  String? get errorMessage => _errorMessage;
  String? get filtroActual => _filtroActual;
  List<String?> get filtros => _filtros;
  DateTime? get mesFiltro => _mesFiltro;
  List<String?> get mesesDisponibles => _mesesDisponibles;

  int get metasCompletadas =>
      _metasAhorro.where((meta) => meta.completada).length;
  int get metasPendientes =>
      _metasAhorro.where((meta) => !meta.completada).length;

<<<<<<< HEAD
=======
  //metodos
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  Future<void> cargarMetasAhorro() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final metas = await _metasAhorroService.obtenerMetasAhorro(userId);
      _metasAhorro = metas;
      _generarMesesDisponibles();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar las metas de ahorro: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _generarMesesDisponibles() {
<<<<<<< HEAD
    _mesesDisponibles = [null];
=======
    // Inicializar con la opción "Todos los meses"
    _mesesDisponibles = [null];

    // Obtener todos los meses únicos de las fechas objetivo
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    Set<String> mesesUnicos = {};

    for (var meta in _metasAhorro) {
      String mesFormateado =
          DateFormat('MMMM yyyy', 'es').format(meta.fechaObjetivo);
      mesesUnicos.add(mesFormateado);
    }

<<<<<<< HEAD
=======
    // Ordenar los meses (primero convertir a DateTime para ordenar cronológicamente)
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    List<DateTime> fechasOrdenadas = [];
    DateFormat formatter = DateFormat('MMMM yyyy', 'es');

    for (String mes in mesesUnicos) {
      try {
        fechasOrdenadas.add(formatter.parse(mes));
      } catch (e) {
        // Ignorar errores de parseo
      }
    }

    fechasOrdenadas.sort();
<<<<<<< HEAD
    List<String> mesesOrdenados =
        fechasOrdenadas.map((fecha) => formatter.format(fecha)).toList();
=======

    // Convertir de nuevo a strings formateados
    List<String> mesesOrdenados =
        fechasOrdenadas.map((fecha) => formatter.format(fecha)).toList();

    // Añadir a la lista de meses disponibles
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    _mesesDisponibles.addAll(mesesOrdenados);
  }

  Future<void> eliminarMetaAhorro(int metaId) async {
    try {
      await _metasAhorroService.eliminarMetaAhorro(userId, metaId);
      await cargarMetasAhorro();
    } catch (e) {
      throw Exception('Error al eliminar la meta de ahorro: $e');
    }
  }

<<<<<<< HEAD
=======
  //metodos de filtrado
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  void cambiarFiltro(String? filtro) {
    _filtroActual = filtro;
    notifyListeners();
  }

  void cambiarMesFiltro(DateTime? mes) {
    _mesFiltro = mes;
    notifyListeners();
  }

  bool _coincideConMesFiltro(MetaAhorro meta) {
    if (_mesFiltro == null) return true;
<<<<<<< HEAD
=======

    // Comparamos solo mes y año
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    return meta.fechaObjetivo.year == _mesFiltro!.year &&
        meta.fechaObjetivo.month == _mesFiltro!.month;
  }

  List<MetaAhorro> get metasFiltradas {
<<<<<<< HEAD
=======
    // Primero aplicamos el filtro por mes
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    List<MetaAhorro> resultado = _mesFiltro == null
        ? List.from(_metasAhorro)
        : _metasAhorro.where(_coincideConMesFiltro).toList();

<<<<<<< HEAD
=======
    // Luego aplicamos el filtro por estado
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    if (_filtroActual == null) {
      return resultado;
    }

    switch (_filtroActual) {
      case 'Completadas':
        return resultado.where((meta) => meta.completada).toList();
      case 'Pendientes':
        return resultado.where((meta) => !meta.completada).toList();
      case 'Vencidas':
        return resultado.where((meta) => estaVencida(meta)).toList();
      case 'Próximas a vencer':
        return resultado
            .where((meta) =>
                !meta.completada &&
                !estaVencida(meta) &&
                diasRestantes(meta) <= 7)
            .toList();
      default:
        return resultado;
    }
  }

<<<<<<< HEAD
  double calcularProgreso(MetaAhorro meta) {
    if (meta.cantidadObjetivo <= 0) return 0.0; // Evitar división por cero
    
    double progreso = meta.cantidadActual / meta.cantidadObjetivo;
    
    // Limitar el progreso entre 0.0 y 1.0
    if (progreso < 0.0) return 0.0;
    if (progreso > 1.0) return 1.0;
    
=======
  //metodos de calculo y utilidad
  double calcularProgreso(MetaAhorro meta) {
    double progreso = meta.cantidadActual / meta.cantidadObjetivo;
    if (progreso > 1) progreso = 1;
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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
<<<<<<< HEAD
      return '$dias días restantes';
    } else if (dias == 0) {
      return 'Vence hoy';
    } else {
      return 'Vencida hace ${-dias} días';
=======
      return '$dias dias restantes';
    } else if (dias == 0) {
      return 'Vence hoy';
    } else {
      return 'Vencida hace ${-dias} dias';
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    }
  }

  IconData obtenerIconoCategoria(String categoria) {
<<<<<<< HEAD
    switch (categoria.toLowerCase()) {
      case 'salario':
        return Icons.payments;
      case 'inversiones':
        return Icons.trending_up;
      case 'freelance':
        return Icons.work;
      case 'regalo':
        return Icons.card_giftcard;
      case 'reembolso':
        return Icons.assignment_return;
      case 'venta':
        return Icons.store;
      case 'otros':
=======
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
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
        return Icons.more_horiz;
      default:
        return Icons.savings;
    }
  }
}
<<<<<<< HEAD


=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
