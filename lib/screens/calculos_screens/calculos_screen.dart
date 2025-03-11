import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/models/calculos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/calculos_screens/seccion_prestamos.dart';
import 'package:flutter_proyecto_app/screens/calculos_screens/seccion_proyecciones.dart';
import 'package:flutter_proyecto_app/screens/calculos_screens/seccion_roi.dart';
import 'package:flutter_proyecto_app/screens/calculos_screens/tiempo_meta.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class CalculosFinancierosScreen extends StatefulWidget {
  final int idUsuario;

  const CalculosFinancierosScreen({super.key, required this.idUsuario});

  @override
  State<CalculosFinancierosScreen> createState() =>
      _CalculosFinancierosScreenState();
}

class _CalculosFinancierosScreenState extends State<CalculosFinancierosScreen>
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
            'Información de Cálculos Financieros',
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
                  'Proyecciones',
                  'Te permite visualizar y proyectar tus finanzas a futuro basado en tus ingresos y gastos actuales. Podrás ver una estimación de tu patrimonio a lo largo del tiempo.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'ROI (Retorno de Inversión)',
                  'Calcula la rentabilidad de una inversión. Introduce el capital inicial, el retorno esperado y el periodo para obtener análisis de rendimiento y recomendaciones.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Préstamos',
                  'Simula préstamos para conocer cuotas mensuales, intereses totales y generar tablas de amortización. Te ayuda a planificar antes de adquirir una deuda.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Tiempo Meta',
                  'Calcula cuánto tiempo tardarás en alcanzar tus metas de ahorro con tu ritmo actual. Incluye recomendaciones personalizadas para optimizar tu estrategia.',
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
      create: (_) => CalculosFinancierosViewModel(idUsuario: widget.idUsuario),
      child: Consumer<CalculosFinancierosViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppTheme.colorFondo,
            drawer: MenuDesplegable(idUsuario: widget.idUsuario),
            appBar: AppBar(
              backgroundColor: AppTheme.colorFondo,
              elevation: 0,
              title: const Text(
                'Cálculos Financieros',
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
                  Tab(text: 'Proyecciones'),
                  Tab(text: 'ROI'),
                  Tab(text: 'Préstamos'),
                  Tab(text: 'Tiempo Meta'),
                ],
                indicatorColor: AppTheme.naranja,
                labelColor: AppTheme.naranja,
                unselectedLabelColor: AppTheme.blanco,
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      ProyeccionesTab(),
                      ROITab(),
                      PrestamosTab(),
                      TiempoMetaTab(),
                    ],
                  ),
            bottomNavigationBar: CustomBottomNavBar(
                idUsuario: widget.idUsuario, currentIndex: 0),
          );
        },
      ),
    );
  }
}


