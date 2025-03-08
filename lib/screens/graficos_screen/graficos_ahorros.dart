import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/graficos_screen/graficos_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SeccionAhorros extends StatelessWidget {
  SeccionAhorros({Key? key}) : super(key: key);

  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GraficosViewModel>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Distribución Ahorros vs Gastos',
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
              _buildStatCard('Ahorros', viewModel.ahorroTotal, Colors.blue, Icons.savings),
              _buildStatCard('Gastos', viewModel.gastosTotales, Colors.red, Icons.money_off),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _buildSavingsChart(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsChart(GraficosViewModel viewModel) {
    final savingsData = [
      ChartData('Ahorros', viewModel.ahorroTotal, Colors.blue),
      ChartData('Gastos', viewModel.gastosTotales, Colors.red),
    ];

    final bool hasSavings = viewModel.ahorroTotal > 0 || viewModel.gastosTotales > 0;

    if (!hasSavings) {
      return _buildEmptyDataMessage('No hay datos de ahorros o gastos disponibles');
    }

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
            child: Text(
              '${viewModel.porcentajeAhorro.toStringAsFixed(1)}%\nAhorrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.blanco,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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
          dataSource: savingsData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.amount,
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
            final total = viewModel.ahorroTotal + viewModel.gastosTotales;
            final percentage = total > 0 ? (data.amount / total * 100).toStringAsFixed(1) : '0.0';
            return '${data.category}: $percentage%';
          },
          animationDuration: 1500,
          explode: true,
          explodeIndex: 0,
          innerRadius: '60%',
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, double amount, Color color, IconData icon) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.blanco,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
