import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/graficos_screens/graficos_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SeccionPresupuesto extends StatelessWidget {
  SeccionPresupuesto({super.key});

  final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GraficosViewModel>(context);

    if (viewModel.presupuestos.isEmpty) {
      return GraficosUIHelpers.buildEmptyDataMessage(
          'No hay presupuestos configurados.\nCrea un presupuesto para ver el analisis.');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPresupuestoResumen(viewModel),
            const SizedBox(height: 24),
            GraficosUIHelpers.buildSectionTitle('Utilizacion del presupuesto'),

            _buildScrollIndicator('Desliza para ver todas las categorias'),
            const SizedBox(height: 12),
            _buildUtilizacionPresupuestoChart(viewModel),
            const SizedBox(height: 16),

            //añado resumen de categorias principales
            _buildCategoriasResumen(viewModel),
            const SizedBox(height: 24),
            GraficosUIHelpers.buildSectionTitle('Detalle por Categoría'),
            const SizedBox(height: 16),
            _buildCategoriasPresupuestoList(viewModel),
          ],
        ),
      ),
    );
  }

  //metodo para mostrar indicador de desplazamiento
  Widget _buildScrollIndicator(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.swipe, color: AppTheme.blanco.withOpacity(0.7), size: 18),
        const SizedBox(width: 8),
        Text(
          message,
          style: TextStyle(
            color: AppTheme.blanco.withOpacity(0.7),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  //metodo para mostrar resumen de categorias principales
  Widget _buildCategoriasResumen(GraficosViewModel viewModel) {
    if (viewModel.presupuestosPorCategoria.isEmpty) {
      return const SizedBox.shrink();
    }

    //obtengo las 3 categorias con mayor uso
    final topCategorias = viewModel.utilizacionPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final categoriasToShow = topCategorias.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.colorFondo.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gris.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorías con mayor utilizacion:',
            style: TextStyle(
              color: AppTheme.blanco,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...categoriasToShow.map((entry) {
            final color = _getColorForUtilizacion(entry.value);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: AppTheme.blanco.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      '${entry.value.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Ver detalle completo abajo ↓',
              style: TextStyle(
                color: AppTheme.blanco.withOpacity(0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
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
                'Resumen de presupuesto',
                style: TextStyle(
                  color: AppTheme.blanco,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              value:
                  porcentajeUtilizado / 100 > 1 ? 1 : porcentajeUtilizado / 100,
              backgroundColor: AppTheme.gris,
              valueColor: AlwaysStoppedAnimation<Color>(colorIndicador),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresupuestoInfoColumn(
      String title, double cantidad, Color textColor) {
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
          formatoMoneda.format(cantidad),
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
      return GraficosUIHelpers.buildEmptyDataMessage(
          'No hay categoriass de presupuesto disponibles');
    }

    final utilizacionData = viewModel.utilizacionPorCategoria.entries
        .map((entry) => ChartData(
            entry.key, entry.value, _getColorForUtilizacion(entry.value)))
        .toList();

    // Ordena por porcentaje de utilizacion, de mayor a menor
    utilizacionData.sort((a, b) => b.cantidad.compareTo(a.cantidad));

    return SizedBox(
      height: 350,
      child: SfCartesianChart(
        margin: const EdgeInsets.all(10),
        plotAreaBackgroundColor: AppTheme.colorFondo.withOpacity(0.7),
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            color: AppTheme.blanco,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          majorGridLines: const MajorGridLines(width: 0),
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          labelAlignment: LabelAlignment.center,
          isVisible: true,
          maximumLabels: 7, // Limitar el número de etiquetas para evitar sobrecarga
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(
            color: AppTheme.blanco,
            fontSize: 12,
          ),
          axisLine: AxisLine(width: 1, color: AppTheme.gris),
          majorGridLines: MajorGridLines(
            width: 1,
            color: AppTheme.gris.withOpacity(0.3),
            dashArray: <double>[5, 5],
          ),
          maximum: 120,
          interval: 20,
          labelFormat: '{value}%',
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: point.y%',
          duration: 1500,
          color: AppTheme.colorFondo.withOpacity(0.9),
          textStyle: const TextStyle(color: AppTheme.blanco),
        ),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
        plotAreaBorderWidth: 0,
        series: <CartesianSeries>[
          ColumnSeries<ChartData, String>(
            dataSource: utilizacionData,
            xValueMapper: (ChartData data, _) => data.categoria,
            yValueMapper: (ChartData data, _) => data.cantidad,
            pointColorMapper: (ChartData data, _) => data.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            // MEJORA: Mostrar las etiquetas solo para valores significativos
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              // Mostrar solo etiquetas para valores mayores a 10%
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                if ((data as ChartData).cantidad < 10) {
                  return Container(); // No mostrar etiqueta para valores pequeños
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${data.cantidad.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              labelAlignment: ChartDataLabelAlignment.top,
              labelPosition: ChartDataLabelPosition.outside,
            ),
            width: 0.8, // Ajustado para mejorar la visualización
            spacing: 0.2,
            animationDuration: 1500,
            name: 'Utilización',
            opacity: 0.9,
          ),
        ],
        annotations: <CartesianChartAnnotation>[
          CartesianChartAnnotation(
            widget: Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 3,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
            coordinateUnit: CoordinateUnit.point,
            region: AnnotationRegion.chart,
            x: utilizacionData.first.categoria,
            y: 100,
          ),
          CartesianChartAnnotation(
            widget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '100% (Límite)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            coordinateUnit: CoordinateUnit.point,
            region: AnnotationRegion.chart,
            x: utilizacionData.length > 1
                ? utilizacionData[1].categoria
                : utilizacionData.first.categoria,
            y: 103,
          ),
        ],
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: const TextStyle(color: AppTheme.blanco),
          iconHeight: 12,
          iconWidth: 12,
        ),
      ),
    );
  }

  Widget _buildCategoriasPresupuestoList(GraficosViewModel viewModel) {
    if (viewModel.presupuestosPorCategoria.isEmpty) {
      return GraficosUIHelpers.buildEmptyDataMessage(
          'No hay categorias de presupuesto disponibles');
    }

    //ordeno las categorias por utilizacion
    final categoriasOrdenadas = viewModel.utilizacionPorCategoria.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
            borderColor: color.withOpacity(0.7),
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                      'Presupuesto: ${formatoMoneda.format(presupuesto)}',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Gasto: ${formatoMoneda.format(gasto)}',
                      style: TextStyle(
                        color: AppTheme.blanco,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Mejora en la visualización de la barra de progreso
                Stack(
                  children: [
                    // Indicador de límite con mejor posicionamiento
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: const Text(
                          '100%',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    //barra de progreso con margen superior para evitar solapamiento
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: utilizacion / 100 > 1 ? 1 : utilizacion / 100,
                          backgroundColor: AppTheme.gris,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _getPresupuestoStatusMessage(utilizacion),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
    if (utilizacion > 100) return Colors.red.shade400;
    if (utilizacion > 80) return Colors.orange.shade400;
    if (utilizacion > 50) return Colors.yellow.shade400;
    return Colors.green.shade400;
  }

  String _getPresupuestoStatusMessage(double utilizacion) {
    if (utilizacion > 100) return 'Presupuesto excedido';
    if (utilizacion > 80) return 'Presupuesto casi agotado';
    if (utilizacion > 50) return 'Presupuesto usandose adecuadamente';
    return 'Presupuesto con disponibilidad amplia';
  }
}


