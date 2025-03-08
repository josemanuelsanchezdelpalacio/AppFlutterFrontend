import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/calculos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/calculos_screen/calculos_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ROITab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculosFinancierosViewModel>(context);
    final resultadosROI = viewModel.calcularROI();
    
    final roi = resultadosROI['roi'];
    final roiAnual = resultadosROI['roiAnual'];
    final gananciaTotal = resultadosROI['gananciaTotal'];
    final gananciaMensual = resultadosROI['gananciaMensual'];
    final proyeccionAnual = resultadosROI['proyeccionAnual'];
    final recomendacion = resultadosROI['recomendacion'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialUIHelpers.buildSectionTitle('Cálculo de ROI'),
          const SizedBox(height: 16),
          
          FinancialUIHelpers.buildInputField(
            label: 'Inversión Inicial',
            initialValue: viewModel.inversionInicial.toString(),
            onChanged: (value) {
              viewModel.setInversionInicial(double.tryParse(value) ?? viewModel.inversionInicial);
            },
            prefixIcon: Icons.attach_money,
          ),
          
          const SizedBox(height: 12),
          
          FinancialUIHelpers.buildInputField(
            label: 'Retorno Esperado',
            initialValue: viewModel.retornoEsperado.toString(),
            onChanged: (value) {
              viewModel.setRetornoEsperado(double.tryParse(value) ?? viewModel.retornoEsperado);
            },
            prefixIcon: Icons.trending_up,
          ),
          
          const SizedBox(height: 12),
          
          FinancialUIHelpers.buildSliderField(
            label: 'Período de Inversión (meses): ${viewModel.periodoInversion}',
            value: viewModel.periodoInversion.toDouble(),
            min: 1,
            max: 60,
            onChanged: (value) {
              viewModel.setPeriodoInversion(value.toInt());
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
                  'ROI: ${roi.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: roi >= 0 ? Colors.green : Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                FinancialUIHelpers.buildResultItem(
                  label: 'ROI Anualizado',
                  value: '${roiAnual.toStringAsFixed(2)}%',
                  color: roiAnual >= 0 ? Colors.green : Colors.red,
                ),
                
                const SizedBox(height: 8),
                
                FinancialUIHelpers.buildResultItem(
                  label: 'Ganancia Total',
                  value: '\$${gananciaTotal.toStringAsFixed(2)}',
                  color: gananciaTotal >= 0 ? Colors.green : Colors.red,
                ),
                
                const SizedBox(height: 8),
                
                FinancialUIHelpers.buildResultItem(
                  label: 'Ganancia Mensual Promedio',
                  value: '\$${gananciaMensual.toStringAsFixed(2)}',
                  color: gananciaMensual >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          FinancialUIHelpers.buildSectionTitle('Recomendaciones'),
          const SizedBox(height: 12),
          
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
                  recomendacion,
                  style: TextStyle(
                    color: roi > 15 
                        ? Colors.green 
                        : roi > 5 
                            ? AppTheme.naranja 
                            : roi > 0 
                                ? Colors.amber 
                                : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Si inviertes la misma cantidad mensualmente, en 1 año tendrías aproximadamente \$${proyeccionAnual.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.blanco,
                    fontSize: 14,
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

