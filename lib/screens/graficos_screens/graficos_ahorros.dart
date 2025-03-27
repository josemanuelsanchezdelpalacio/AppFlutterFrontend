import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
<<<<<<< HEAD
=======
import 'package:flutter_proyecto_app/screens/graficos_screens/graficos_screen.dart';
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

<<<<<<< HEAD
// Definición local de ChartData
class ChartData {
  final String categoria;
  final double cantidad;
  final Color color;

  ChartData(this.categoria, this.cantidad, this.color);
}

=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
class SeccionAhorros extends StatelessWidget {
  SeccionAhorros({super.key});

  final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GraficosViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Distribución Financiera',
            style: TextStyle(
              color: AppTheme.blanco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Ingresos', viewModel.ingresosTotales,
                  Colors.green, Icons.arrow_upward),
              _buildStatCard(
                  'Ahorros', viewModel.ahorroTotal, Colors.blue, Icons.savings),
              _buildStatCard('Gastos', viewModel.gastosTotales, Colors.red,
                  Icons.money_off),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _buildFinancialChart(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialChart(GraficosViewModel viewModel) {
    final financialData = [
      ChartData('Ingresos', viewModel.ingresosTotales, Colors.green),
      ChartData('Ahorros', viewModel.ahorroTotal, Colors.blue),
      ChartData('Gastos', viewModel.gastosTotales, Colors.red),
    ];

    final bool hasData = viewModel.ingresosTotales > 0 ||
        viewModel.ahorroTotal > 0 ||
        viewModel.gastosTotales > 0;

    if (!hasData) {
      return _buildEmptyDataMessage('No hay datos financieros disponibles');
    }

    final total = viewModel.ingresosTotales;
    final porcentajeAhorro =
        total > 0 ? (viewModel.ahorroTotal / total * 100) : 0;
    final porcentajeGastos =
        total > 0 ? (viewModel.gastosTotales / total * 100) : 0;

    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: TextStyle(color: AppTheme.blanco),
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${porcentajeAhorro.toStringAsFixed(1)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.blanco,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ahorrado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.blanco,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: point.y',
        header: '',
      ),
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: financialData,
          xValueMapper: (ChartData data, _) => data.categoria,
          yValueMapper: (ChartData data, _) => data.cantidad,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.line,
              length: '15%',
            ),
            textStyle: TextStyle(color: AppTheme.blanco, fontSize: 12),
          ),
          dataLabelMapper: (ChartData data, _) {
            double percentage = 0;
            if (data.categoria == 'Ingresos' && total > 0) {
              percentage = 100;
            } else if (data.categoria == 'Ahorros' && total > 0) {
              percentage = porcentajeAhorro.toDouble();
            } else if (data.categoria == 'Gastos' && total > 0) {
              percentage = porcentajeGastos.toDouble();
            }
            return '${data.categoria}: ${percentage.toStringAsFixed(1)}%';
          },
          animationDuration: 1500,
          explode: true,
          explodeIndex: 1, // Índice de la sección Ahorros
          innerRadius: '60%',
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, double amount, Color color, IconData icon) {
    return Container(
      width: 105,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.blanco,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDataMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: AppTheme.naranja, size: 48),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppTheme.blanco, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
=======

>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
