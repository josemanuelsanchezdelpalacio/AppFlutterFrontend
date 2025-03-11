import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/componentesUI_calculos.dart';
import 'package:flutter_proyecto_app/models/calculos_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class PrestamosTab extends StatelessWidget {
  const PrestamosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculosFinancierosViewModel>(context);
    final resultadosPrestamo = viewModel.calcularPrestamo();
    final tablaAmortizacion = viewModel.calcularTablaAmortizacion();

    final cuotaMensual = resultadosPrestamo['cuotaMensual'];
    final totalPagado = resultadosPrestamo['totalPagado'];
    final totalIntereses = resultadosPrestamo['totalIntereses'];
    final tasaMensual = resultadosPrestamo['tasaMensual'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentesuiCalculos.buildSeccionTitulo('Cálculo de Préstamos'),
          const SizedBox(height: 16),
          ComponentesuiCalculos.buildCampos(
            label: 'Monto del Préstamo',
            initialValue: viewModel.montoPrestamo.toString(),
            onChanged: (value) {
              viewModel.setMontoPrestamo(
                  double.tryParse(value) ?? viewModel.montoPrestamo);
            },
            prefixIcon: Icons.attach_money,
          ),
          const SizedBox(height: 12),
          ComponentesuiCalculos.buildCampos(
            label: 'Tasa de interes anual (%)',
            initialValue: viewModel.tasaInteres.toString(),
            onChanged: (value) {
              viewModel.setTasaInteres(
                  double.tryParse(value) ?? viewModel.tasaInteres);
            },
            prefixIcon: Icons.percent,
          ),
          const SizedBox(height: 12),
          ComponentesuiCalculos.buildCampoDeslizante(
            label: 'Plazo del Prestamo (meses): ${viewModel.plazoPrestamo}',
            value: viewModel.plazoPrestamo.toDouble(),
            min: 1,
            max: 60,
            onChanged: (value) {
              viewModel.setPlazoPrestamo(value.toInt());
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gris.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuota mensual: \$${cuotaMensual.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.blanco,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ComponentesuiCalculos.buildItemResultados(
                  label: 'Tasa mensual',
                  value: '${tasaMensual.toStringAsFixed(2)}%',
                  color: AppTheme.blanco,
                ),
                const SizedBox(height: 8),
                ComponentesuiCalculos.buildItemResultados(
                  label: 'Total a pagar',
                  value: '\$${totalPagado.toStringAsFixed(2)}',
                  color: AppTheme.blanco,
                ),
                const SizedBox(height: 8),
                ComponentesuiCalculos.buildItemResultados(
                  label: 'Total intereses',
                  value: '\$${totalIntereses.toStringAsFixed(2)}',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ComponentesuiCalculos.buildSeccionTitulo('Tabla de amortizacion'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.gris.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                headingRowColor: WidgetStateProperty.all(AppTheme.gris),
                dataRowColor: WidgetStateProperty.all(Colors.transparent),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Mes',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Cuota',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Interes',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Amortizacion',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Saldo Restante',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: tablaAmortizacion.map((row) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${row['mes']}',
                          style: const TextStyle(color: AppTheme.blanco),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${row['cuota'].toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.blanco),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${row['interes'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${row['amortizacion'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${row['saldo'].toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.naranja),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

