import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/calculos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/calculos_screen/calculos_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ProyeccionesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculosFinancierosViewModel>(context);
    final proyecciones = viewModel.calcularProyecciones();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialUIHelpers.buildSectionTitle('Proyección de Ahorro'),
          const SizedBox(height: 16),
          
          FinancialUIHelpers.buildInputField(
            label: 'Ingreso Mensual',
            initialValue: viewModel.ingresoMensual.toString(),
            onChanged: (value) {
              viewModel.setIngresoMensual(double.tryParse(value) ?? viewModel.ingresoMensual);
            },
            prefixIcon: Icons.attach_money,
          ),
          
          const SizedBox(height: 12),
          
          FinancialUIHelpers.buildInputField(
            label: 'Gasto Mensual',
            initialValue: viewModel.gastoMensual.toString(),
            onChanged: (value) {
              viewModel.setGastoMensual(double.tryParse(value) ?? viewModel.gastoMensual);
            },
            prefixIcon: Icons.shopping_cart,
          ),
          
          const SizedBox(height: 12),
          
          FinancialUIHelpers.buildSliderField(
            label: 'Meses de Proyección: ${viewModel.mesesProyeccion}',
            value: viewModel.mesesProyeccion.toDouble(),
            min: 3,
            max: 36,
            onChanged: (value) {
              viewModel.setMesesProyeccion(value.toInt());
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
                  'Ahorro Mensual Proyectado: \$${viewModel.ahorroMensual.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.blanco,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ahorro Total en ${viewModel.mesesProyeccion} meses: \$${(viewModel.ahorroMensual * viewModel.mesesProyeccion).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.naranja,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Proyección por Mes',
            style: TextStyle(
              color: AppTheme.blanco,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Tabla de proyecciones
          Container(
            decoration: BoxDecoration(
              color: AppTheme.gris.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                headingRowColor: MaterialStateProperty.all(AppTheme.gris),
                dataRowColor: MaterialStateProperty.all(Colors.transparent),
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
                      'Ingresos',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Gastos',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Ahorro',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Acumulado',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: proyecciones.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          p['mes'],
                          style: const TextStyle(color: AppTheme.blanco),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${p['ingresos'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${p['gastos'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${p['ahorro'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${p['saldoAcumulado'].toStringAsFixed(2)}',
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
