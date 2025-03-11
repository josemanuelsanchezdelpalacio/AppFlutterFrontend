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

  //parametros para proyecciones
  double _ahorroMensual = 0;
  double _gastoMensual = 0;
  double _ingresoMensual = 0;
  int _mesesProyeccion = 6;

  //parametros para ROI
  double _inversionInicial = 0;
  double _retornoEsperado = 0;
  int _periodoInversion = 12;

  //parametros para préstamos
  double _montoPrestamo = 0;
  double _tasaInteres = 0;
  int _plazoPrestamo = 12;

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

  //formateador para las cantidades monetarias
  final NumberFormat currencyFormat = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  );

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
      _ingresoMensual = double.parse(ingresos.toStringAsFixed(2));
      _gastoMensual = double.parse(gastos.toStringAsFixed(2));
      _ahorroMensual = double.parse((_ingresoMensual - _gastoMensual).toStringAsFixed(2));
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
    _ahorroMensual = double.parse((_ingresoMensual - _gastoMensual).toStringAsFixed(2));
    notifyListeners();
  }

  void setGastoMensual(double valor) {
    _gastoMensual = double.parse(valor.toStringAsFixed(2));
    _ahorroMensual = double.parse((_ingresoMensual - _gastoMensual).toStringAsFixed(2));
    notifyListeners();
  }

  void setMesesProyeccion(int meses) {
    _mesesProyeccion = meses;
    notifyListeners();
  }

  void setAhorroMensual(double valor) {
    _ahorroMensual = double.parse(valor.toStringAsFixed(2));
    notifyListeners();
  }

  // Formateadores para mostrar en UI
  String formatearCantidad(double valor) {
    return currencyFormat.format(valor);
  }

  //setters para valores de ROI
  void setInversionInicial(double valor) {
    _inversionInicial = double.parse(valor.toStringAsFixed(2));
    notifyListeners();
  }

  void setRetornoEsperado(double valor) {
    _retornoEsperado = double.parse(valor.toStringAsFixed(2));
    notifyListeners();
  }

  void setPeriodoInversion(int periodo) {
    _periodoInversion = periodo;
    notifyListeners();
  }

  //setters para valores de prestamos
  void setMontoPrestamo(double valor) {
    _montoPrestamo = double.parse(valor.toStringAsFixed(2));
    notifyListeners();
  }

  void setTasaInteres(double valor) {
    _tasaInteres = double.parse(valor.toStringAsFixed(2));
    notifyListeners();
  }

  void setPlazoPrestamo(int plazo) {
    _plazoPrestamo = plazo;
    notifyListeners();
  }

  //calculos de Proyecciones
  List<Map<String, dynamic>> calcularProyecciones() {
    List<Map<String, dynamic>> proyecciones = [];
    double saldoAcumulado = 0;

    final ahora = DateTime.now();

    for (int i = 0; i < _mesesProyeccion; i++) {
      final mesProyectado = DateTime(ahora.year, ahora.month + i, 1);
      saldoAcumulado = double.parse((saldoAcumulado + _ahorroMensual).toStringAsFixed(2));

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

  //calculos de ROI
  Map<String, dynamic> calcularROI() {
    double roi = _inversionInicial > 0
        ? double.parse((((_retornoEsperado - _inversionInicial) / _inversionInicial) * 100).toStringAsFixed(2))
        : 0;

    double roiAnual = double.parse((roi / (_periodoInversion / 12)).toStringAsFixed(2));
    double gananciaTotal = double.parse((_retornoEsperado - _inversionInicial).toStringAsFixed(2));
    double gananciaMensual = double.parse((gananciaTotal / _periodoInversion).toStringAsFixed(2));
    double proyeccionAnual = double.parse((_inversionInicial * 12 * (1 + (roi / 100) / 12)).toStringAsFixed(2));

    return {
      'roi': roi,
      'roiAnual': roiAnual,
      'gananciaTotal': gananciaTotal,
      'gananciaMensual': gananciaMensual,
      'proyeccionAnual': proyeccionAnual,
      'recomendacion': roi > 15
          ? 'Esta inversión muestra un rendimiento excelente.'
          : roi > 5
              ? 'Esta inversión muestra un rendimiento aceptable.'
              : roi > 0
                  ? 'Esta inversión muestra un rendimiento bajo.'
                  : 'Esta inversión no es rentable.'
    };
  }

  // Cálculos de prestamos
  Map<String, dynamic> calcularPrestamo() {
    double tasaMensual = double.parse((_tasaInteres / 100 / 12).toStringAsFixed(6));
    double cuotaMensual = 0;

    if (tasaMensual > 0) {
      cuotaMensual = _montoPrestamo *
          tasaMensual *
          pow(1 + tasaMensual, _plazoPrestamo) /
          (pow(1 + tasaMensual, _plazoPrestamo) - 1);
      cuotaMensual = double.parse(cuotaMensual.toStringAsFixed(2));
    }

    double totalPagado = double.parse((cuotaMensual * _plazoPrestamo).toStringAsFixed(2));
    double totalIntereses = double.parse((totalPagado - _montoPrestamo).toStringAsFixed(2));
    double tasaMensualPorcentaje = double.parse((tasaMensual * 100).toStringAsFixed(2));

    return {
      'cuotaMensual': cuotaMensual,
      'totalPagado': totalPagado,
      'totalIntereses': totalIntereses,
      'tasaMensual': tasaMensualPorcentaje,
    };
  }

  //amortizacion para prestamos
  List<Map<String, dynamic>> calcularTablaAmortizacion() {
    List<Map<String, dynamic>> tablaAmortizacion = [];
    double tasaMensual = double.parse((_tasaInteres / 100 / 12).toStringAsFixed(6));
    double cuotaMensual = 0;

    if (tasaMensual > 0) {
      cuotaMensual = _montoPrestamo *
          tasaMensual *
          pow(1 + tasaMensual, _plazoPrestamo) /
          (pow(1 + tasaMensual, _plazoPrestamo) - 1);
      cuotaMensual = double.parse(cuotaMensual.toStringAsFixed(2));
    }

    double saldoPendiente = _montoPrestamo;

    for (int i = 1; i <= _plazoPrestamo; i++) {
      double interesMensual = double.parse((saldoPendiente * tasaMensual).toStringAsFixed(2));
      double amortizacion = double.parse((cuotaMensual - interesMensual).toStringAsFixed(2));
      saldoPendiente = double.parse((saldoPendiente - amortizacion).toStringAsFixed(2));

      //corrijo posibles errores de redondeo en el ultimo mes
      if (i == _plazoPrestamo) {
        amortizacion = double.parse((amortizacion + saldoPendiente).toStringAsFixed(2));
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

  //calculos para metas de ahorro
  List<Map<String, dynamic>> calcularTiempoMetas() {
    List<Map<String, dynamic>> resultados = [];

    //si no hay metas o el ahorro mensual es 0 devuelvo la lista vacia
    if (metasAhorro.isEmpty) {
      return resultados;
    }

    for (var meta in metasAhorro) {
      double montoFaltante = double.parse((meta.cantidadObjetivo - meta.cantidadActual).toStringAsFixed(2));

      //calculo porcentaje de avance
      double porcentajeCompletado = 0.0;
      if (meta.cantidadObjetivo > 0) {
        porcentajeCompletado = double.parse(
            ((meta.cantidadActual / meta.cantidadObjetivo) * 100).toStringAsFixed(2));
        //limito el porcentaje entre 0 y 100
        porcentajeCompletado = porcentajeCompletado.clamp(0.0, 100.0);
      }

      //calculo meses estimados
      int mesesEstimados = 0;
      DateTime? fechaEstimada;
      String recomendacion = '';

      if (montoFaltante > 0) {
        if (ahorroMensual > 0) {
          //calculo meses y compruebo que no sea infinito
          double mesesDouble = montoFaltante / ahorroMensual;
          if (mesesDouble.isFinite && !mesesDouble.isNaN) {
            mesesEstimados = mesesDouble.ceil(); //redondeo

            //calculo fecha estimada
            fechaEstimada =
                DateTime.now().add(Duration(days: (mesesEstimados * 30)));

            //genero la recomendacion
            if (mesesEstimados > 24) {
              recomendacion =
                  'Considera aumentar tu ahorro mensual para alcanzar tu meta mas rapido';
            } else if (mesesEstimados > 12) {
              recomendacion = 'Vas por buen camino, manten tu ritmo de ahorro.';
            } else {
              recomendacion =
                  'Estas muy cerca de alcanzar tu meta.';
            }
          } else {
            recomendacion =
                'No se puede calcular el tiempo estimado. Verifica tus datos.';
          }
        } else {
          recomendacion =
              'Ingresa una cantidad de ahorro mensual para calcular el tiempo estimado.';
        }
      } else {
        // La meta ya se ha alcanzado
        recomendacion = 'Has alcanzado tu meta de ahorro.';
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

  //funcion auxiliar para calculos de potencia
  double pow(double x, int y) {
    double result = 1.0;
    for (int i = 0; i < y; i++) {
      result *= x;
    }
    return double.parse(result.toStringAsFixed(6));
  }
}

