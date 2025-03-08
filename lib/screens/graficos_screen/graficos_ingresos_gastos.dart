import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SeccionIngresosGastos extends StatelessWidget {
  SeccionIngresosGastos({Key? key}) : super(key: key);

  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final dateFormat = DateFormat('dd MMM');

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GraficosViewModel>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolución de Ingresos y Gastos',
            style: TextStyle(
              color: AppTheme.blanco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Seguimiento diario de tus finanzas',
            style: TextStyle(
              color: AppTheme.blanco.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _buildTimeSeriesChart(viewModel),
          ),
          SizedBox(height: 16),
          _buildSummaryCards(viewModel),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesChart(GraficosViewModel viewModel) {
    // Preparar datos para el gráfico de líneas
    List<TransactionData> ingresosDiarios = [];
    List<TransactionData> gastosDiarios = [];

    // Agrupar transacciones por día
    Map<DateTime, double> mapIngresosDiarios = {};
    Map<DateTime, double> mapGastosDiarios = {};

    // Normalizar fechas para que solo tenga en cuenta el día (sin horas)
    for (var t in viewModel.transacciones) {
      final fechaSinHora = DateTime(
        t.fechaTransaccion.year,
        t.fechaTransaccion.month,
        t.fechaTransaccion.day,
      );

      if (t.tipoTransaccion == TipoTransacciones.INGRESO) {
        mapIngresosDiarios[fechaSinHora] = 
            (mapIngresosDiarios[fechaSinHora] ?? 0) + t.cantidad;
      } else {
        mapGastosDiarios[fechaSinHora] = 
            (mapGastosDiarios[fechaSinHora] ?? 0) + t.cantidad;
      }
    }

    // Ordenar fechas cronológicamente para el gráfico
    final todasLasFechas = {...mapIngresosDiarios.keys, ...mapGastosDiarios.keys}.toList()
      ..sort();

    // Crear listas ordenadas para el gráfico
    for (var fecha in todasLasFechas) {
      ingresosDiarios.add(TransactionData(
        fecha, 
        mapIngresosDiarios[fecha] ?? 0
      ));
      
      gastosDiarios.add(TransactionData(
        fecha, 
        mapGastosDiarios[fecha] ?? 0
      ));
    }

    // Si no hay datos, mostrar mensaje apropiado
    if (ingresosDiarios.isEmpty && gastosDiarios.isEmpty) {
      return _buildEmptyDataMessage('No hay datos de transacciones disponibles');
    }

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.all(10),
      primaryXAxis: DateTimeAxis(
        dateFormat: dateFormat,
        intervalType: DateTimeIntervalType.days,
        majorGridLines: MajorGridLines(width: 0.5, color: AppTheme.blanco.withOpacity(0.2)),
        axisLine: AxisLine(width: 1, color: AppTheme.naranja),
        labelStyle: TextStyle(color: AppTheme.blanco),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: currencyFormat,
        labelStyle: TextStyle(color: AppTheme.blanco),
        axisLine: AxisLine(width: 1, color: AppTheme.naranja),
        majorGridLines: MajorGridLines(width: 0.5, color: AppTheme.blanco.withOpacity(0.2)),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'Fecha: {point.x}\nMonto: {point.y}',
        header: '',
        canShowMarker: true,
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: TextStyle(color: AppTheme.blanco),
        iconHeight: 12,
        iconWidth: 12,
      ),
      series: <CartesianSeries<TransactionData, DateTime>>[
        // Línea de ingresos
        LineSeries<TransactionData, DateTime>(
          dataSource: ingresosDiarios,
          xValueMapper: (TransactionData data, _) => data.date,
          yValueMapper: (TransactionData data, _) => data.amount,
          name: 'Ingresos',
          color: Colors.green,
          width: 2.5,
          markerSettings: MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
            color: Colors.green,
          ),
          animationDuration: 1500,
          enableTooltip: true,
        ),
        // Línea de gastos
        LineSeries<TransactionData, DateTime>(
          dataSource: gastosDiarios,
          xValueMapper: (TransactionData data, _) => data.date,
          yValueMapper: (TransactionData data, _) => data.amount,
          name: 'Gastos',
          color: Colors.red,
          width: 2.5,
          markerSettings: MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
            color: Colors.red,
          ),
          animationDuration: 1500,
          enableTooltip: true,
        ),
      ],
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        zoomMode: ZoomMode.x,
      ),
    );
  }

  Widget _buildSummaryCards(GraficosViewModel viewModel) {
    return Row(
      children: [
        _buildSummaryCard(
          'Ingresos',
          viewModel.ingresosTotales,
          Icons.arrow_upward,
          Colors.green,
        ),
        SizedBox(width: 12),
        _buildSummaryCard(
          'Gastos',
          viewModel.gastosTotales,
          Icons.arrow_downward,
          Colors.red,
        ),
        SizedBox(width: 12),
        _buildSummaryCard(
          'Balance',
          viewModel.ahorroTotal,
          Icons.account_balance_wallet,
          viewModel.ahorroTotal >= 0 ? Colors.blue : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.colorFondo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.blanco.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              currencyFormat.format(amount),
              style: TextStyle(
                color: AppTheme.blanco,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDataMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline_outlined, color: AppTheme.naranja, size: 48),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppTheme.blanco, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Text(
            'Agrega transacciones para ver su evolución en el tiempo',
            style: TextStyle(color: AppTheme.blanco.withOpacity(0.7), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Clase para los datos del gráfico de líneas
class TransactionData {
  final DateTime date;
  final double amount;

  TransactionData(this.date, this.amount);
}