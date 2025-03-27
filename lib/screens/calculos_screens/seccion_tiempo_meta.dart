import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/componentesUI_calculos.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/models/calculos_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SeccionTiempoMeta extends StatelessWidget {
  
  const SeccionTiempoMeta({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculosFinancierosViewModel>(context);
    final resultadosMetas = viewModel.calcularTiempoMetas();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentesuiCalculos.buildSeccionTitulo('Tiempo para alcanzar metas'),
          const SizedBox(height: 16),
          ComponentesuiCalculos.buildCampos(
            label: 'Ahorro mensual estimado',
            initialValue: viewModel.formatearCantidad(viewModel.ahorroMensual),
            onChanged: (value) {
              //eliminacion del simbolo de moneda y comas para procesar
              String cleanedValue = value.replaceAll(',', '');
              double? parsedValue = double.tryParse(cleanedValue);
              viewModel
                  .setAhorroMensual(parsedValue ?? viewModel.ahorroMensual);
            },
            prefixIcon: Icons.savings,
          ),
          const SizedBox(height: 24),
          resultadosMetas.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.gris.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No tienes metas de ahorro activas',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: resultadosMetas.length,
                  itemBuilder: (context, index) {
                    final resultado = resultadosMetas[index];
                    final meta = resultado['meta'] as MetaAhorro;
                    final montoFaltante = resultado['montoFaltante'] as double;

                    int mesesEstimados = 0;
                    if (resultado['mesesEstimados'] is int) {
                      mesesEstimados = resultado['mesesEstimados'] as int;
                    } else if (resultado['mesesEstimados'] is double) {
                      final mesesDouble = resultado['mesesEstimados'] as double;
                      if (mesesDouble.isFinite && !mesesDouble.isNaN) {
                        mesesEstimados = mesesDouble.toInt();
                      }
                    }

                    final porcentajeCompletado =
                        resultado['porcentajeCompletado'] as double;
                    final fechaEstimada =
                        resultado['fechaEstimada'] as DateTime?;
                    final recomendacion = resultado['recomendacion'] as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.gris.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  meta.nombre,
                                  style: const TextStyle(
                                    color: AppTheme.naranja,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${porcentajeCompletado.isFinite ? porcentajeCompletado.toStringAsFixed(1) : "0.0"}%',
                                style: const TextStyle(
                                  color: AppTheme.blanco,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: porcentajeCompletado.isFinite
                                  ? (porcentajeCompletado / 100).clamp(0.0, 1.0)
                                  : 0.0,
                              minHeight: 10,
                              backgroundColor: AppTheme.gris,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  porcentajeCompletado < 25
                                      ? Colors.red
                                      : porcentajeCompletado < 50
                                          ? Colors.orange
                                          : porcentajeCompletado < 75
                                              ? Colors.yellow
                                              : Colors.green),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ComponentesuiCalculos.buildItemResultados(
                                  label: 'Cantidad objetivo',
                                  value:
                                      '\$${meta.cantidadObjetivo.toStringAsFixed(2)}',
                                  color: AppTheme.blanco,
                                ),
                              ),
                              Expanded(
                                child: ComponentesuiCalculos.buildItemResultados(
                                  label: 'Cantidad actual',
                                  value:
                                      '\$${meta.cantidadActual.toStringAsFixed(2)}',
                                  color: AppTheme.blanco,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ComponentesuiCalculos.buildItemResultados(
                                  label: 'Falta por ahorrar',
                                  value:
                                      '\$${montoFaltante.isFinite ? montoFaltante.toStringAsFixed(2) : "0.00"}',
                                  color: montoFaltante <= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Expanded(
                                child: ComponentesuiCalculos.buildItemResultados(
                                  label: 'Tiempo estimado',
                                  value: viewModel.ahorroMensual <= 0
                                      ? 'N/A'
                                      : mesesEstimados == 0
                                          ? 'Completado'
                                          : '$mesesEstimados meses',
                                  color: AppTheme.blanco,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (fechaEstimada != null)
                            Text(
                              'Fecha estimada: ${DateFormat('MMMM yyyy').format(fechaEstimada)}',
                              style: const TextStyle(
                                color: AppTheme.naranja,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            recomendacion,
                            style: const TextStyle(
                              color: AppTheme.blanco,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}


