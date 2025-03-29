import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';
import 'package:intl/intl.dart';

class PresupuestosViewModel extends ChangeNotifier {
  final int userId;
  final PresupuestosService _service = PresupuestosService();
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Presupuesto> _presupuestos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _filtroActual;
  DateTime? _mesFiltro;

  final List<String?> filtros = [
    null,
    'Completados',
    'En curso',
    'Vencidos',
    'Próximos a vencer'
  ];

  List<String?> _mesesFiltro = [null];

  PresupuestosViewModel(this.userId) {
    _initNotifications();
  }

  List<Presupuesto> get presupuestos => _presupuestos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get filtroActual => _filtroActual;
  DateTime? get mesFiltro => _mesFiltro;
  List<String?> get mesesFiltro => _mesesFiltro;

  int get presupuestosCompletados =>
      _presupuestos.where((p) => estaCompletado(p)).length;
  int get presupuestosEnCurso =>
      _presupuestos.where((p) => !estaCompletado(p) && !estaVencido(p)).length;
  int get presupuestosSuperados => presupuestosCompletados;

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _mostrarNotificacion(String titulo, String cuerpo) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('presupuestos_channel', 'Presupuestos',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await notificationsPlugin.show(0, titulo, cuerpo, platformChannelSpecifics);
  }

  Future<void> cargarPresupuestos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _presupuestos = await _service.obtenerPresupuestos(userId);
      _actualizarMesesDisponibles();
      
      // Verificar presupuestos completados
      for (var presupuesto in _presupuestos) {
        if (presupuesto.cantidadGastada >= presupuesto.cantidad && 
            !presupuesto.completado) {
          await _mostrarNotificacion(
            'Presupuesto completado',
            '¡Has completado el presupuesto de ${presupuesto.categoria}!'
          );
          presupuesto.completado = true;
          await _service.actualizarPresupuesto(
              userId, presupuesto.id!, presupuesto);
        }
      }
      
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron cargar los presupuestos. ${e.toString()}';
    }
    notifyListeners();
  }

  void _actualizarMesesDisponibles() {
    Set<String> mesesUnicos = {};

    for (var presupuesto in _presupuestos) {
      String mesInicio =
          DateFormat('MMMM yyyy', 'es').format(presupuesto.fechaInicio);
      mesesUnicos.add(mesInicio);

      String mesFin =
          DateFormat('MMMM yyyy', 'es').format(presupuesto.fechaFin);
      mesesUnicos.add(mesFin);

      DateTime fechaActual = DateTime(
          presupuesto.fechaInicio.year, presupuesto.fechaInicio.month + 1, 1);
      while (fechaActual.isBefore(presupuesto.fechaFin)) {
        mesesUnicos.add(DateFormat('MMMM yyyy', 'es').format(fechaActual));
        fechaActual = DateTime(fechaActual.year, fechaActual.month + 1, 1);
      }
    }

    List<String> mesesOrdenados = mesesUnicos.toList()
      ..sort((a, b) {
        try {
          DateTime fechaA = DateFormat('MMMM yyyy', 'es').parse(a);
          DateTime fechaB = DateFormat('MMMM yyyy', 'es').parse(b);
          return fechaA.compareTo(fechaB);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    _mesesFiltro = [null, ...mesesOrdenados];
    notifyListeners();
  }

  Future<void> eliminarPresupuesto(int presupuestoId) async {
    try {
      await _service.eliminarPresupuesto(userId, presupuestoId);
      _presupuestos.removeWhere((p) => p.id == presupuestoId);
      _actualizarMesesDisponibles();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al eliminar el presupuesto: ${e.toString()}';
      notifyListeners();
    }
  }

  double calcularProgreso(Presupuesto presupuesto) {
    if (presupuesto.cantidad == 0) return 0.0;
    return (presupuesto.cantidadGastada / presupuesto.cantidad).clamp(0.0, 1.0);
  }

  bool estaVencido(Presupuesto presupuesto) {
    return DateTime.now().isAfter(presupuesto.fechaFin);
  }

  bool estaCompletado(Presupuesto presupuesto) {
    return presupuesto.completado || 
        (presupuesto.cantidadGastada >= presupuesto.cantidad);
  }

  IconData obtenerIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'comida':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'entretenimiento':
        return Icons.movie;
      case 'servicios':
        return Icons.cleaning_services;
      case 'compras':
        return Icons.shopping_cart;
      case 'salud':
        return Icons.medical_services;
      case 'educación':
        return Icons.school;
      case 'otros':
        return Icons.category;
      default:
        return Icons.money;
    }
  }

  void setFiltro(String? filtro) {
    _filtroActual = filtro;
    notifyListeners();
  }

  void setMesFiltro(DateTime? mes) {
    _mesFiltro = mes;
    notifyListeners();
  }

  bool presupuestoEnMes(Presupuesto presupuesto, DateTime mes) {
    DateTime inicioMes = DateTime(mes.year, mes.month, 1);
    DateTime finMes = (mes.month < 12)
        ? DateTime(mes.year, mes.month + 1, 1).subtract(const Duration(days: 1))
        : DateTime(mes.year + 1, 1, 1).subtract(const Duration(days: 1));

    return presupuesto.fechaInicio
            .isBefore(finMes.add(const Duration(days: 1))) &&
        presupuesto.fechaFin
            .isAfter(inicioMes.subtract(const Duration(days: 1)));
  }

  int diasRestantes(Presupuesto presupuesto) {
    return presupuesto.fechaFin.difference(DateTime.now()).inDays;
  }

  String obtenerTextoTiempoRestante(Presupuesto presupuesto) {
    final dias = diasRestantes(presupuesto);
    if (dias > 0) {
      return '$dias días restantes';
    } else if (dias == 0) {
      return 'Vence hoy';
    } else {
      return 'Vencido hace ${-dias} días';
    }
  }

  List<Presupuesto> get presupuestosFiltrados {
    List<Presupuesto> presupuestosFiltradosPorMes = _presupuestos;

    if (_mesFiltro != null) {
      presupuestosFiltradosPorMes =
          _presupuestos.where((p) => presupuestoEnMes(p, _mesFiltro!)).toList();
    }

    if (_filtroActual == null) {
      return presupuestosFiltradosPorMes;
    }

    final fechaActual = DateTime.now();
    switch (_filtroActual) {
      case 'Completados':
        return presupuestosFiltradosPorMes
            .where((p) => estaCompletado(p))
            .toList();
      case 'En curso':
        return presupuestosFiltradosPorMes
            .where((p) => !estaCompletado(p) && !estaVencido(p))
            .toList();
      case 'Vencidos':
        return presupuestosFiltradosPorMes
            .where((p) => estaVencido(p))
            .toList();
      case 'Próximos a vencer':
        return presupuestosFiltradosPorMes.where((p) {
          final diferencia = p.fechaFin.difference(fechaActual).inDays;
          return !estaVencido(p) && diferencia <= 7 && diferencia >= 0;
        }).toList();
      default:
        return presupuestosFiltradosPorMes;
    }
  }

  @override
  void dispose() {
    notificationsPlugin.cancelAll();
    super.dispose();
  }
}

