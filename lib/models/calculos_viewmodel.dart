import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';

class CalculosFinancierosViewModel extends ChangeNotifier {
  final int idUsuario;
  final TransaccionesService _transaccionesService = TransaccionesService();
  final MetasAhorroService _metasAhorroService = MetasAhorroService();

  bool _isLoading = true;
  List<MetaAhorro> _metasAhorro = [];

  // Parámetros para proyecciones
  double _ahorroMensual = 0;
  double _gastoMensual = 0;
  double _ingresoMensual = 0;
  int _mesesProyeccion = 6;

  // Parámetros para ROI
  double _inversionInicial = 0;
  double _retornoEsperado = 0;
  int _periodoInversion = 12;

  // Parámetros para préstamos
  double _montoPrestamo = 0;
  double _tasaInteres = 0;
  int _plazoPrestamo = 12;

  // Getters
  bool get isLoading => _isLoading;
  double get ahorroMensual => _ahorroMensual;
  double get gastoMensual => _gastoMensual;
  double get ingresoMensual => _ingresoMensual;
  int get mesesProyeccion => _mesesProyeccion;
  double get inversionInicial => _inversionInicial;
  double get retornoEsperado => _retornoEsperado;
  int get periodoInversion => _periodoInversion;
  double get montoPrestamo => _montoPrestamo;
  double get tasaInteres => _tasaInteres;
  int get plazoPrestamo => _plazoPrestamo;
  List<MetaAhorro> get metasAhorro => _metasAhorro;

  CalculosFinancierosViewModel({required this.idUsuario}) {
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final transacciones =
          await _transaccionesService.obtenerTransacciones(idUsuario);
      final metasAhorro =
          await _metasAhorroService.obtenerMetasAhorro(idUsuario);

      // Calcular promedios mensuales
      final ahora = DateTime.now();
      final unMesAtras = DateTime(ahora.year, ahora.month - 1, ahora.day);

      final transaccionesMesActual = transacciones
          .where((t) => !t.fechaTransaccion.isBefore(unMesAtras))
          .toList();

      double ingresos = 0;
      double gastos = 0;

      for (var t in transaccionesMesActual) {
        if (t.tipoTransaccion == TipoTransacciones.INGRESO) {
          ingresos += t.cantidad;
        } else {
          gastos += t.cantidad;
        }
      }

      _metasAhorro = metasAhorro;
      _ingresoMensual = ingresos;
      _gastoMensual = gastos;
      _ahorroMensual = ingresos - gastos;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error al cargar datos: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setters para valores de proyecciones
  void setIngresoMensual(double valor) {
    _ingresoMensual = double.parse(valor.toStringAsFixed(2));
    _ahorroMensual = _ingresoMensual - _gastoMensual;
    notifyListeners();
  }

  void setGastoMensual(double valor) {
    _gastoMensual = double.parse(valor.toStringAsFixed(2));
    _ahorroMensual = _ingresoMensual - _gastoMensual;
    notifyListeners();
  }

  void setMesesProyeccion(int meses) {
    _mesesProyeccion = meses;
    notifyListeners();
  }

  void setAhorroMensual(double valor) {
    _ahorroMensual = valor;
    notifyListeners();
  }

  // Setters para valores de ROI
  void setInversionInicial(double valor) {
    _inversionInicial = valor;
    notifyListeners();
  }

  void setRetornoEsperado(double valor) {
    _retornoEsperado = valor;
    notifyListeners();
  }

  void setPeriodoInversion(int periodo) {
    _periodoInversion = periodo;
    notifyListeners();
  }

  // Setters para valores de préstamos
  void setMontoPrestamo(double valor) {
    _montoPrestamo = valor;
    notifyListeners();
  }

  void setTasaInteres(double valor) {
    _tasaInteres = valor;
    notifyListeners();
  }

  void setPlazoPrestamo(int plazo) {
    _plazoPrestamo = plazo;
    notifyListeners();
  }

  // Cálculos de Proyecciones
  List<Map<String, dynamic>> calcularProyecciones() {
    List<Map<String, dynamic>> proyecciones = [];
    double saldoAcumulado = 0;

    final ahora = DateTime.now();

    for (int i = 0; i < _mesesProyeccion; i++) {
      final mesProyectado = DateTime(ahora.year, ahora.month + i, 1);
      saldoAcumulado += _ahorroMensual;

      proyecciones.add({
        'mes': DateFormat('MMMM yyyy').format(mesProyectado),
        'ingresos': _ingresoMensual,
        'gastos': _gastoMensual,
        'ahorro': _ahorroMensual,
        'saldoAcumulado': saldoAcumulado,
      });
    }

    return proyecciones;
  }

  // Cálculos de ROI
  Map<String, dynamic> calcularROI() {
    double roi = _inversionInicial > 0
        ? ((_retornoEsperado - _inversionInicial) / _inversionInicial) * 100
        : 0;

    double roiAnual = roi / (_periodoInversion / 12);

    return {
      'roi': roi,
      'roiAnual': roiAnual,
      'gananciaTotal': _retornoEsperado - _inversionInicial,
      'gananciaMensual':
          (_retornoEsperado - _inversionInicial) / _periodoInversion,
      'proyeccionAnual': _inversionInicial * 12 * (1 + (roi / 100) / 12),
      'recomendacion': roi > 15
          ? 'Esta inversión muestra un rendimiento excelente.'
          : roi > 5
              ? 'Esta inversión muestra un rendimiento aceptable.'
              : roi > 0
                  ? 'Esta inversión muestra un rendimiento bajo.'
                  : 'Esta inversión no es rentable.'
    };
  }

  // Cálculos de Préstamos
  Map<String, dynamic> calcularPrestamo() {
    double tasaMensual = _tasaInteres / 100 / 12;
    double cuotaMensual = 0;

    if (tasaMensual > 0) {
      cuotaMensual = _montoPrestamo *
          tasaMensual *
          pow(1 + tasaMensual, _plazoPrestamo) /
          (pow(1 + tasaMensual, _plazoPrestamo) - 1);
    }

    double totalPagado = cuotaMensual * _plazoPrestamo;
    double totalIntereses = totalPagado - _montoPrestamo;

    return {
      'cuotaMensual': cuotaMensual,
      'totalPagado': totalPagado,
      'totalIntereses': totalIntereses,
      'tasaMensual': tasaMensual * 100,
    };
  }

  // Tabla de amortización para préstamos
  List<Map<String, dynamic>> calcularTablaAmortizacion() {
    List<Map<String, dynamic>> tablaAmortizacion = [];
    double tasaMensual = _tasaInteres / 100 / 12;
    double cuotaMensual = 0;

    if (tasaMensual > 0) {
      cuotaMensual = _montoPrestamo *
          tasaMensual *
          pow(1 + tasaMensual, _plazoPrestamo) /
          (pow(1 + tasaMensual, _plazoPrestamo) - 1);
    }

    double saldoPendiente = _montoPrestamo;

    for (int i = 1; i <= _plazoPrestamo; i++) {
      double interesMensual = saldoPendiente * tasaMensual;
      double amortizacion = cuotaMensual - interesMensual;
      saldoPendiente -= amortizacion;

      // Corregir posibles errores de redondeo en el último mes
      if (i == _plazoPrestamo) {
        amortizacion += saldoPendiente;
        saldoPendiente = 0;
      }

      tablaAmortizacion.add({
        'mes': i,
        'cuota': cuotaMensual,
        'interes': interesMensual,
        'amortizacion': amortizacion,
        'saldo': saldoPendiente,
      });
    }

    return tablaAmortizacion;
  }

  // Cálculos para metas de ahorro
  List<Map<String, dynamic>> calcularTiempoMetas() {
    List<Map<String, dynamic>> resultados = [];

    // Si no hay metas o el ahorro mensual es 0, devolver lista vacía
    if (metasAhorro.isEmpty) {
      return resultados;
    }

    for (var meta in metasAhorro) {
      double montoFaltante = meta.cantidadObjetivo - meta.cantidadActual;

      // Calcular porcentaje de avance
      double porcentajeCompletado = 0.0;
      if (meta.cantidadObjetivo > 0) {
        porcentajeCompletado =
            (meta.cantidadActual / meta.cantidadObjetivo) * 100;
        // Limitar el porcentaje entre 0 y 100
        porcentajeCompletado = porcentajeCompletado.clamp(0.0, 100.0);
      }

      // Calcular meses estimados - evitar división por cero
      int mesesEstimados = 0;
      DateTime? fechaEstimada;
      String recomendacion = '';

      if (montoFaltante > 0) {
        if (ahorroMensual > 0) {
          // Calcular meses y verificar que no sea infinito o NaN
          double mesesDouble = montoFaltante / ahorroMensual;
          if (mesesDouble.isFinite && !mesesDouble.isNaN) {
            mesesEstimados = mesesDouble.ceil(); // Redondeamos hacia arriba

            // Calcular fecha estimada
            fechaEstimada =
                DateTime.now().add(Duration(days: (mesesEstimados * 30)));

            // Generar recomendación
            if (mesesEstimados > 24) {
              recomendacion =
                  'Considera aumentar tu ahorro mensual para alcanzar tu meta más rápido.';
            } else if (mesesEstimados > 12) {
              recomendacion = 'Vas por buen camino, mantén tu ritmo de ahorro.';
            } else {
              recomendacion =
                  '¡Excelente! Estás muy cerca de alcanzar tu meta.';
            }
          } else {
            recomendacion =
                'No se puede calcular el tiempo estimado. Verifica tus datos.';
          }
        } else {
          recomendacion =
              'Ingresa un monto de ahorro mensual para calcular el tiempo estimado.';
        }
      } else {
        // La meta ya se ha alcanzado
        recomendacion = '¡Felicidades! Has alcanzado tu meta de ahorro.';
      }

      resultados.add({
        'meta': meta,
        'montoFaltante': montoFaltante,
        'mesesEstimados': mesesEstimados,
        'porcentajeCompletado': porcentajeCompletado,
        'fechaEstimada': fechaEstimada,
        'recomendacion': recomendacion,
      });
    }

    return resultados;
  }

  // Función auxiliar para cálculos de potencia
  double pow(double x, int y) {
    double result = 1.0;
    for (int i = 0; i < y; i++) {
      result *= x;
    }
    return result;
  }
}
