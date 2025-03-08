import 'package:flutter/foundation.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';

class HomeViewModel extends ChangeNotifier {
  final int userId;
  
  final TransaccionesService _transaccionesService = TransaccionesService();
  final PresupuestosService _presupuestosService = PresupuestosService();
  final MetasAhorroService _metasAhorroService = MetasAhorroService();
  
  List<Transaccion> _ultimasTransacciones = [];
  List<Presupuesto> _presupuestos = [];
  List<MetaAhorro> _metasAhorro = [];
  double _balanceTotal = 0;
  double _ingresosTotal = 0;
  double _gastosTotal = 0;
  
  bool _isLoading = true;
  String _errorMessage = '';

  // Getters
  List<Transaccion> get ultimasTransacciones => _ultimasTransacciones;
  List<Presupuesto> get presupuestos => _presupuestos;
  List<MetaAhorro> get metasAhorro => _metasAhorro;
  double get balanceTotal => _balanceTotal;
  double get ingresosTotal => _ingresosTotal;
  double get gastosTotal => _gastosTotal;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  HomeViewModel(this.userId);

  Future<void> cargarDatos() async {
    _setLoading(true);
    _setError('');

    try {
      // Cargar transacciones del último mes
      final DateTime ahora = DateTime.now();
      final DateTime inicioMes = DateTime(ahora.year, ahora.month, 1);
      
      final transacciones = await _transaccionesService.obtenerTransaccionesPorFecha(
        userId, 
        inicioMes, 
        ahora
      );
      
      // Calcular totales
      double ingresos = 0;
      double gastos = 0;
      
      for (var transaccion in transacciones) {
        if (transaccion.tipoTransaccion == TipoTransacciones.INGRESO) {
          ingresos += transaccion.cantidad;
        } else if (transaccion.tipoTransaccion == TipoTransacciones.GASTO) {
          gastos += transaccion.cantidad;
        }
      }
      
      // Obtener presupuestos activos
      final presupuestos = await _presupuestosService.obtenerPresupuestos(userId);
      final presupuestosActivos = presupuestos.where((p) => 
        p.fechaFin.isAfter(DateTime.now())
      ).toList();
      
      // Obtener metas de ahorro no completadas
      final metasAhorro = await _metasAhorroService.obtenerMetasAhorro(userId);
      final metasNoCompletadas = metasAhorro.where((m) => !m.completada).toList();
      
      // Ordenar transacciones por fecha (recientes primero) y limitar a 5
      transacciones.sort((a, b) => b.fechaTransaccion.compareTo(a.fechaTransaccion));
      final ultimasTransacciones = transacciones.take(5).toList();
      
      _ultimasTransacciones = ultimasTransacciones;
      _presupuestos = presupuestosActivos;
      _metasAhorro = metasNoCompletadas;
      _ingresosTotal = ingresos;
      _gastosTotal = gastos;
      _balanceTotal = ingresos - gastos;
      _setLoading(false);

    } catch (e) {
      _setError('Error al cargar los datos: $e');
      _setLoading(false);
    }
    
    notifyListeners();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
  }
  
  void _setError(String message) {
    _errorMessage = message;
  }
}
