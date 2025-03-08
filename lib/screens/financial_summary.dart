import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FinancialSummaryScreen extends StatelessWidget {
  final int idUsuario;

  const FinancialSummaryScreen({Key? key, required this.idUsuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GraficosViewModel>(context);
    
    // Formato de moneda
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    // Principales categorías de gasto
    final topExpenses = viewModel.obtenerPrincipalesGastos(3);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card de Balance General
          Card(
            elevation: 4,
            color: AppTheme.gris.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.naranja.withOpacity(0.5), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance General',
                        style: TextStyle(
                          color: AppTheme.blanco,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.account_balance_wallet, color: AppTheme.naranja),
                    ],
                  ),
                  const Divider(color: AppTheme.naranja, height: 20),
                  _buildSummaryRow('Ingresos Totales', currencyFormat.format(viewModel.ingresosTotales), Colors.green),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Gastos Totales', currencyFormat.format(viewModel.gastosTotales), Colors.red),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Ahorros Totales',
                    currencyFormat.format(viewModel.ahorroTotal),
                    viewModel.ahorroTotal >= 0 ? Colors.blue : Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Card de Porcentajes
          Card(
            elevation: 4,
            color: AppTheme.gris.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.naranja.withOpacity(0.5), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Distribución',
                        style: TextStyle(
                          color: AppTheme.blanco,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.pie_chart, color: AppTheme.naranja),
                    ],
                  ),
                  const Divider(color: AppTheme.naranja, height: 20),
                  _buildProgressBar('Ahorro', viewModel.porcentajeAhorro, Colors.blue),
                  const SizedBox(height: 12),
                  _buildProgressBar('Gastos', viewModel.porcentajeGastos, Colors.red),
                  const SizedBox(height: 12),
                  _buildProgressBar(
                    'Presupuesto Utilizado',
                    viewModel.utilizacionPresupuesto,
                    viewModel.utilizacionPresupuesto > 100 ? Colors.red : Colors.orange,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Card de Tendencias
          Card(
            elevation: 4,
            color: AppTheme.gris.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.naranja.withOpacity(0.5), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tendencias',
                        style: TextStyle(
                          color: AppTheme.blanco,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.trending_up, color: AppTheme.naranja),
                    ],
                  ),
                  const Divider(color: AppTheme.naranja, height: 20),
                  _buildTendencyRow('Ingresos', viewModel.tendenciaIngresos),
                  const SizedBox(height: 8),
                  _buildTendencyRow('Gastos', viewModel.tendenciaGastos),
                  const SizedBox(height: 8),
                  _buildTendencyRow('Ahorros', viewModel.tendenciaAhorro),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Card de Principales Gastos
          if (topExpenses.isNotEmpty)
            Card(
              elevation: 4,
              color: AppTheme.gris.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.naranja.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Text(
                        'Principales Gastos',
                        style: TextStyle(
                          color: AppTheme.blanco,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.money_off, color: AppTheme.naranja),
                    ],
                    ),
                    const Divider(color: AppTheme.naranja, height: 20),
                    ...topExpenses
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(color: AppTheme.blanco, fontSize: 16),
                                  ),
                                  Text(
                                    currencyFormat.format(entry.value),
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, Color color) {
    return Row(
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
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String title, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.blanco,
                fontSize: 14,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage > 100 ? 1 : percentage / 100,
            color: color,
            backgroundColor: AppTheme.gris,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTendencyRow(String title, double trend) {
    final isPositive = trend >= 0;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final textColor = title == 'Gastos'
        ? (isPositive ? Colors.red : Colors.green)
        : (isPositive ? Colors.green : Colors.red);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.blanco,
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 4),
            Text(
              '${trend.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}