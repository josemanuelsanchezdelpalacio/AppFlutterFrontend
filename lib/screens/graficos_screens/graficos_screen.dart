import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/screens/graficos_screens/graficos_ahorros.dart';
import 'package:flutter_proyecto_app/screens/graficos_screens/graficos_ingresos_gastos.dart';
import 'package:flutter_proyecto_app/screens/graficos_screens/graficos_presupuesto.dart';
import 'package:flutter_proyecto_app/screens/graficos_screens/graficos_resumen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ChartData {
  final String categoria;
  final double cantidad;
  final Color color;

  ChartData(this.categoria, this.cantidad, [this.color = Colors.blue]);
}

class GraficosScreen extends StatefulWidget {
  final int idUsuario;

  const GraficosScreen({super.key, required this.idUsuario});

  @override
  State<GraficosScreen> createState() => _GraficosScreenState();
}

class _GraficosScreenState extends State<GraficosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _mostrarInfoCard() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.colorFondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: AppTheme.naranja, width: 2),
          ),
          title: const Text(
            'Información de Gráficos Financieros',
            style: TextStyle(
              color: AppTheme.naranja,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoSection(
                  'Resumen',
                  'Visualiza un resumen general de tus finanzas, incluyendo ingresos, gastos, ahorros y la utilización de tu presupuesto con indicadores claros.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Ingresos/Gastos',
                  'Analiza tus ingresos y gastos por categoría para entender mejor de dónde proviene tu dinero y dónde lo estás utilizando.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Ahorros',
                  'Visualiza la proporción de tus ahorros respecto a tus gastos y monitorea el porcentaje de dinero que estás guardando.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Presupuesto',
                  'Verifica el cumplimiento de tu presupuesto por categorías y el porcentaje de utilización para mantener tus finanzas bajo control.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: AppTheme.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _infoSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.naranja,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            color: AppTheme.blanco,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraficosViewModel()..cargarDatos(widget.idUsuario),
      child: Scaffold(
        backgroundColor: AppTheme.colorFondo,
        drawer: MenuDesplegable(idUsuario: widget.idUsuario),
        appBar: AppBar(
          backgroundColor: AppTheme.colorFondo,
          elevation: 0,
          title: const Text(
            'Resumen Financiero',
            style: TextStyle(
              color: AppTheme.blanco,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: AppTheme.blanco),
              onPressed: _mostrarInfoCard,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Resumen'),
              Tab(text: 'Ingresos/Gastos'),
              Tab(text: 'Ahorros'),
              Tab(text: 'Presupuesto'),
            ],
            indicatorColor: AppTheme.naranja,
            labelColor: AppTheme.naranja,
            unselectedLabelColor: AppTheme.blanco,
          ),
        ),
        body: Consumer<GraficosViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.naranja),
                    SizedBox(height: 16),
                    Text(
                      'Cargando datos financieros...',
                      style: TextStyle(color: AppTheme.blanco, fontSize: 16),
                    )
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                SeccionResumen(),
                SeccionIngresosGastos(),
                SeccionAhorros(),
                SeccionPresupuesto(),
              ],
            );
          },
        ),
        bottomNavigationBar:
            CustomBottomNavBar(idUsuario: widget.idUsuario, currentIndex: 0),
      ),
    );
  }
}

// Clase para compartir utilidades de UI entre las secciones
class GraficosUIHelpers {
  static Widget buildEmptyDataMessage(String message) {
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

  static Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.blanco,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget buildCardContainer(
      {required Widget child, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gris.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      child: child,
    );
  }
}
