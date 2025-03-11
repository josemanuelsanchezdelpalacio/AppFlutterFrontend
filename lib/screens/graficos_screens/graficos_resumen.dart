import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SeccionResumen extends StatelessWidget {
  SeccionResumen({super.key});

  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GraficosViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader(viewModel),
          const SizedBox(height: 20),
          _buildSummaryItem('Ingresos Totales', viewModel.ingresosTotales,
              Colors.green, Icons.arrow_upward),
          const SizedBox(height: 12),
          _buildSummaryItem('Gastos Totales', viewModel.gastosTotales,
              Colors.red, Icons.arrow_downward),
          const SizedBox(height: 12),
          _buildSummaryItem('Ahorros Totales', viewModel.ahorroTotal,
              Colors.blue, Icons.savings),
          const SizedBox(height: 12),
          _buildProgressItem('Utilización del Presupuesto',
              viewModel.utilizacionPresupuesto, Colors.orange),
          const SizedBox(height: 12),
          _buildProgressItem(
              'Porcentaje de Ahorro', viewModel.porcentajeAhorro, Colors.blue),
          const SizedBox(height: 12),
          _buildProgressItem(
              'Porcentaje de Gastos', viewModel.porcentajeGastos, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(GraficosViewModel viewModel) {
    final netBalance = viewModel.ingresosTotales - viewModel.gastosTotales;
    final isPositive = netBalance >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isPositive ? Colors.green : Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Balance total',
                style: TextStyle(
                  color: AppTheme.blanco,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(netBalance),
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPositive ? 'Balance positivo' : 'Balance negativo',
            style: TextStyle(
              color: AppTheme.blanco,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String title, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.gris.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.blanco,
                  fontSize: 16,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 10,
              backgroundColor: AppTheme.gris.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.gris.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.blanco,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(value),
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

