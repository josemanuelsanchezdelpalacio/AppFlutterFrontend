import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/models/exportar_datos_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ExportarDatosScreen extends StatefulWidget {
  final int idUsuario;

  const ExportarDatosScreen({super.key, required this.idUsuario});

  @override
  State<ExportarDatosScreen> createState() => _ExportarDatosScreenState();
}

class _ExportarDatosScreenState extends State<ExportarDatosScreen> {
  late ExportarDatosViewmodel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ExportarDatosViewmodel(idUsuario: widget.idUsuario);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exportar datos'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: viewModel.cargarDatos,
              tooltip: 'Recargar datos',
            )
          ],
        ),
        drawer: MenuDesplegable(idUsuario: widget.idUsuario),
        body: Consumer<ExportarDatosViewmodel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    'Todos tus datos en un solo lugar',
                    'Exporta toda tu informacion financiera',
                    Icons.info_outline,
                  ),
                  const SizedBox(height: 24),
                  _buildResumenFinanciero(model),
                  const SizedBox(height: 24),
                  _buildOpcionesExportar(model),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar:
            BarraInferiorSecciones(idUsuario: widget.idUsuario, indexActual: 0),
      ),
    );
  }

  Widget _buildInfoCard(String title, String message, IconData icon) {
    return Card(
      color: AppTheme.gris,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.naranja, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.blanco,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.blanco.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenFinanciero(ExportarDatosViewmodel model) {
    return Card(
      color: AppTheme.gris,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.blanco,
              ),
            ),
            const SizedBox(height: 16),
            _buildItemResumen(
              Icons.receipt_long,
              'Transacciones',
              model.transaccionesExistentes
                  ? '${model.transacciones.length} registros'
                  : 'No hay datos',
              model.transaccionesExistentes,
            ),
            const Divider(color: Colors.grey),
            _buildItemResumen(
              Icons.account_balance_wallet,
              'Presupuestos',
              model.presupuestosExistentes
                  ? '${model.presupuestos.length} registros'
                  : 'No hay datos',
              model.presupuestosExistentes,
            ),
            const Divider(color: Colors.grey),
            _buildItemResumen(
              Icons.savings,
              'Metas de Ahorro',
              model.metasExistentes
                  ? '${model.metasAhorro.length} registros'
                  : 'No hay datos',
              model.metasExistentes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemResumen(
      IconData icon, String title, String count, bool hasData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: hasData ? AppTheme.naranja : Colors.grey, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.blanco,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasData ? AppTheme.blanco : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionesExportar(ExportarDatosViewmodel model) {
    return Card(
      color: AppTheme.gris,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Formatos de exportacion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.blanco,
              ),
            ),
            const SizedBox(height: 16),
            _buildBotonExportar(
              'Exportar como PDF',
              'Documento con tablas formateadas',
              Icons.picture_as_pdf,
              model.hasAnyData ? () => model.exportarPDF() : null,
            ),
            const SizedBox(height: 12),
            _buildBotonExportar(
              'Exportar como CSV',
              'Para Excel y otras hojas de calculo',
              Icons.table_chart,
              model.hasAnyData ? () => model.exportarDatosACSV() : null,
            ),
            const SizedBox(height: 12),
            _buildBotonExportar(
              'Exportar como JSON',
              'Para desarrolladores y aplicaciones',
              Icons.code,
              model.hasAnyData ? () => model.exportarDatosAJson() : null,
            ),
            if (!model.hasAnyData)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    'No hay datos para exportar',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonExportar(String titulo, String subtitulo, IconData icono,
      VoidCallback? onPressed) {
    final isDisabled = onPressed == null;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey[800] : AppTheme.naranja,
        foregroundColor: isDisabled ? Colors.grey : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(icono, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.grey : Colors.black,
                  ),
                ),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDisabled ? Colors.grey[400] : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDisabled ? Colors.grey : Colors.black54,
          ),
        ],
      ),
    );
  }
}
