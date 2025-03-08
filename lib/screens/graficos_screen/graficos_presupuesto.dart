import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/graficos_screen/graficos_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SeccionPresupuesto extends StatelessWidget {
  SeccionPresupuesto({Key? key}) : super(key: key);

  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GraficosViewModel>(context);
    
    if (viewModel.presupuestos.isEmpty) {
      return GraficosUIHelpers.buildEmptyDataMessage(
        'No hay presupuestos configurados.\nCrea un presupuesto para ver el análisis.'
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPresupuestoResumen(viewModel),
            const SizedBox(height: 24),
            GraficosUIHelpers.buildSectionTitle('Utilización del Presupuesto'),
            const SizedBox(height: 16),
            _buildUtilizacionPresupuestoChart(viewModel),
            const SizedBox(height: 24),
            GraficosUIHelpers.buildSectionTitle('Detalle por Categoría'),
            const SizedBox(height: 16),
            _buildCategoriasPresupuestoList(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildPresupuestoResumen(GraficosViewModel viewModel) {
    final porcentajeUtilizado = viewModel.utilizacionPresupuesto;
    final colorIndicador = porcentajeUtilizado > 100 
        ? Colors.red 
        : porcentajeUtilizado > 80 
          ? Colors.orange 
          : Colors.green;

    return GraficosUIHelpers.buildCardContainer(
      borderColor: colorIndicador,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumen de Presupuesto',
                style: TextStyle(
                  color: AppTheme.blanco,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorIndicador.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorIndicador),
                ),
                child: Text(
                  '${porcentajeUtilizado.toStringAsFixed(1)}% Utilizado',
                  style: TextStyle(
                    color: colorIndicador,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPresupuestoInfoColumn(
                'Presupuesto Total',
                viewModel.presupuestoTotal,
                AppTheme.blanco,
              ),
              _buildPresupuestoInfoColumn(
                'Gastos Realizados',
                viewModel.gastosTotales,
                Colors.red,
              ),
              _buildPresupuestoInfoColumn(
                'Disponible',
                viewModel.presupuestoRestante,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: porcentajeUtilizado / 100 > 1 ? 1 : porcentajeUtilizado / 100,
              backgroundColor: AppTheme.gris,
              valueColor: AlwaysStoppedAnimation<Color>(colorIndicador),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresupuestoInfoColumn(String title, double amount, Color textColor) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.blanco,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUtilizacionPresupuestoChart(GraficosViewModel viewModel) {
    if (viewModel.presupuestosPorCategoria.isEmpty) {
      return GraficosUIHelpers.buildEmptyDataMessage('No hay categorías de presupuesto disponibles');
    }

    final utilizacionData = viewModel.utilizacionPorCategoria.entries
        .map((entry) => ChartData(
              entry.key, 
              entry.value, 
              _getColorForUtilizacion(entry.value)
            ))
        .toList();

    // Ordena por porcentaje de utilización, de mayor a menor
    utilizacionData.sort((a, b) => b.amount.compareTo(a.amount));

    return Container(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(color: AppTheme.blanco),
          majorGridLines: MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(color: AppTheme.blanco),
          axisLine: AxisLine(width: 0),
          maximum: 120, // Para mostrar hasta 120%
          interval: 20,
          labelFormat: '{value}%',
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: point.y%',
        ),
        plotAreaBorderWidth: 0,
        series: <CartesianSeries>[
          ColumnSeries<ChartData, String>(
            dataSource: utilizacionData,
            xValueMapper: (ChartData data, _) => data.category,
            yValueMapper: (ChartData data, _) => data.amount,
            pointColorMapper: (ChartData data, _) => data.color,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(color: AppTheme.blanco, fontSize: 12),
              labelAlignment: ChartDataLabelAlignment.top,
              labelPosition: ChartDataLabelPosition.inside,
            ),
            width: 0.7,
            animationDuration: 1500,
            name: 'Utilización',
          ),
        ],
        annotations: <CartesianChartAnnotation>[
          CartesianChartAnnotation(
            widget: Container(
              width: double.infinity,
              height: 2,
              color: Colors.red.withOpacity(0.7),
            ),
            coordinateUnit: CoordinateUnit.point,
            region: AnnotationRegion.chart,
            x: utilizacionData.first.category,
            y: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasPresupuestoList(GraficosViewModel viewModel) {
    if (viewModel.presupuestosPorCategoria.isEmpty) {
      return GraficosUIHelpers.buildEmptyDataMessage('No hay categorías de presupuesto disponibles');
    }

    // Ordenar categorías por utilización
    final categoriasOrdenadas = viewModel.utilizacionPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categoriasOrdenadas.length,
      itemBuilder: (context, index) {
        final categoria = categoriasOrdenadas[index].key;
        final utilizacion = categoriasOrdenadas[index].value;
        final presupuesto = viewModel.presupuestosPorCategoria[categoria] ?? 0;
        final gasto = viewModel.gastosPorCategoria[categoria] ?? 0;
        final color = _getColorForUtilizacion(utilizacion);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GraficosUIHelpers.buildCardContainer(
            borderColor: color.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        categoria,
                        style: TextStyle(
                          color: AppTheme.blanco,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        '${utilizacion.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Presupuesto: ${currencyFormat.format(presupuesto)}',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Gasto: ${currencyFormat.format(gasto)}',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: utilizacion / 100 > 1 ? 1 : utilizacion / 100,
                    backgroundColor: AppTheme.gris,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getPresupuestoStatusMessage(utilizacion),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorForUtilizacion(double utilizacion) {
    if (utilizacion > 100) return Colors.red;
    if (utilizacion > 80) return Colors.orange;
    if (utilizacion > 50) return Colors.yellow;
    return Colors.green;
  }

  String _getPresupuestoStatusMessage(double utilizacion) {
    if (utilizacion > 100) return 'Presupuesto excedido';
    if (utilizacion > 80) return 'Presupuesto casi agotado';
    if (utilizacion > 50) return 'Presupuesto utilizándose adecuadamente';
    return 'Presupuesto con disponibilidad amplia';
  }
}

