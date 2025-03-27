import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';
import 'package:intl/intl.dart';

class PresupuestosViewModel extends ChangeNotifier {
  final int userId;
  final PresupuestosService _service = PresupuestosService();

  List<Presupuesto> _presupuestos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _filtroActual;
  DateTime? _mesFiltro;

  //lista de filtros disponibles para presupuestos
  final List<String?> filtros = [
    null,
    'Superados',
    'En curso',
    'Vencidos',
    'Próximos a vencer'
  ];

  //lista de meses disponibles para filtrar
  List<String?> _mesesFiltro = [null];

  List<Presupuesto> get presupuestos => _presupuestos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get filtroActual => _filtroActual;
  DateTime? get mesFiltro => _mesFiltro;
  List<String?> get mesesFiltro => _mesesFiltro;

  //getters para si la cantidad de los presupuestos se superan o si estan en curso
  int get presupuestosSuperados =>
      _presupuestos.where((p) => estaSuperado(p)).length;

  int get presupuestosEnCurso =>
      _presupuestos.where((p) => !estaSuperado(p) && !estaVencido(p)).length;

  PresupuestosViewModel(this.userId);

  //metodo para obtener los presupuestos
  Future<void> cargarPresupuestos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _presupuestos = await _service.obtenerPresupuestos(userId);
      _actualizarMesesDisponibles(); //acutlizo la lista de meses disponibles
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudieron cargar los presupuestos. ${e.toString()}';
    }
    notifyListeners();
  }

  //metodo para actualizar la lista de meses disponibles segun los presupuestos cargados
  void _actualizarMesesDisponibles() {
    Set<String> mesesUnicos = {};

    for (var presupuesto in _presupuestos) {
      //añado mes de fecha inicio
      String mesInicio =
          DateFormat('MMMM yyyy', 'es').format(presupuesto.fechaInicio);
      mesesUnicos.add(mesInicio);

      //añado mes de fecha fin si es diferente
      String mesFin =
          DateFormat('MMMM yyyy', 'es').format(presupuesto.fechaFin);
      mesesUnicos.add(mesFin);

      //añado meses intermedios si hay mas de un mes entre fechas
      DateTime fechaActual = DateTime(
          presupuesto.fechaInicio.year, presupuesto.fechaInicio.month + 1, 1);
      while (fechaActual.isBefore(presupuesto.fechaFin)) {
        mesesUnicos.add(DateFormat('MMMM yyyy', 'es').format(fechaActual));
        fechaActual = DateTime(fechaActual.year, fechaActual.month + 1, 1);
      }
    }

    //convierto a lista y ordenar cronologicamente
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

    //actualizo la lista de meses con todos los meses como primera opcion
    _mesesFiltro = [null, ...mesesOrdenados];
  }

  //metodo para eliminar presupuestos
  Future<void> eliminarPresupuesto(int presupuestoId) async {
    try {
      await _service.eliminarPresupuesto(userId, presupuestoId);
      _presupuestos.removeWhere((p) => p.id == presupuestoId);
      _actualizarMesesDisponibles(); //actualizo la lista de meses despues de eliminar
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al eliminar el presupuesto: ${e.toString()}';
      notifyListeners();
    }
  }

  //metodo para calcular el progreso de un presupuesto
  double calcularProgreso(Presupuesto presupuesto) {
    if (presupuesto.cantidad == 0) return 0.0;
    return (presupuesto.cantidadGastada) / presupuesto.cantidad;
  }

  //metodo para comprobar si el presupuesto esta vencido
  bool estaVencido(Presupuesto presupuesto) {
    return DateTime.now().isAfter(presupuesto.fechaFin);
  }

  //metodo para comprobar si el presupuesto ha sido superado
  bool estaSuperado(Presupuesto presupuesto) {
    return (presupuesto.cantidadGastada) > presupuesto.cantidad;
  }

  // metodo para obtener icono de categoria
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

  //para cambiar el filtro actual
  void setFiltro(String? filtro) {
    _filtroActual = filtro;
    notifyListeners();
  }

  //para establecer el mes de filtro
  void setMesFiltro(DateTime? mes) {
    _mesFiltro = mes;
    notifyListeners();
  }

  //metodo para convertir un texto de mes a objeto
  DateTime? mesTextoAFecha(String? mesTexto) {
    if (mesTexto == null) return null;
    try {
      return DateFormat('MMMM yyyy', 'es').parse(mesTexto);
    } catch (e) {
      return null;
    }
  }

  //metodo para verificar si un presupuesto pertenece al mes seleccionado
  bool presupuestoEnMes(Presupuesto presupuesto, DateTime mes) {
    //compruebo si el período del presupuesto incluye el mes seleccionado
    DateTime inicioMes = DateTime(mes.year, mes.month, 1);
    DateTime finMes = (mes.month < 12)
        ? DateTime(mes.year, mes.month + 1, 1).subtract(const Duration(days: 1))
        : DateTime(mes.year + 1, 1, 1).subtract(const Duration(days: 1));

    //el prresupuesto incluye el mes si:
    //la fecha de inicio es anterior o igual al final del mes Y
    //la fecha de fin es posterior o igual al inicio del mes
    return presupuesto.fechaInicio
            .isBefore(finMes.add(const Duration(days: 1))) &&
        presupuesto.fechaFin
            .isAfter(inicioMes.subtract(const Duration(days: 1)));
  }

  //lista para obtener presupuestos filtrados segun el filtro actual y el mes seleccionado
  List<Presupuesto> get presupuestosFiltrados {
    //aplico el filtro de mes si existe
    List<Presupuesto> presupuestosFiltradosPorMes = _presupuestos;

    if (_mesFiltro != null) {
      presupuestosFiltradosPorMes =
          _presupuestos.where((p) => presupuestoEnMes(p, _mesFiltro!)).toList();
    }

    //luego aplico el filtro de estado
    if (_filtroActual == null) {
      return presupuestosFiltradosPorMes;
    }

    final fechaActual = DateTime.now();
    switch (_filtroActual) {
      case 'Superados':
        return presupuestosFiltradosPorMes
            .where((p) => estaSuperado(p))
            .toList();
      case 'En curso':
        return presupuestosFiltradosPorMes
            .where((p) => !estaSuperado(p) && !estaVencido(p))
            .toList();
      case 'Vencidos':
        return presupuestosFiltradosPorMes
            .where((p) => estaVencido(p))
            .toList();
      case 'Próximos a vencer':
        return presupuestosFiltradosPorMes.where((p) {
          //compruebo si vence en los proximos 7 dias
          final diferencia = p.fechaFin.difference(fechaActual).inDays;
          return !estaVencido(p) && diferencia <= 7 && diferencia >= 0;
        }).toList();
      default:
        return presupuestosFiltradosPorMes;
    }
  }
}



