import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/graficos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/add_metas_ahorro_screen.dart';
import 'package:flutter_proyecto_app/screens/add_presupuestos_screen.dart';
import 'package:flutter_proyecto_app/screens/add_transacciones_screen.dart';
import 'package:flutter_proyecto_app/screens/calculos_screens/calculos_screen.dart';
import 'package:flutter_proyecto_app/screens/graficos_screens/graficos_screen.dart';
import 'package:flutter_proyecto_app/screens/exportar_datos_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MenuDesplegable extends StatelessWidget {
  final int idUsuario;

  const MenuDesplegable({super.key, required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.colorFondo,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.gris,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/imagen_logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Menú',
                  style: TextStyle(
                    color: AppTheme.blanco,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildMenuItem(
            icon: Icons.calculate,
            title: 'Calculos',
            onTap: () => _navegarA(
              context,
              CalculosFinancierosScreen(idUsuario: idUsuario),
            ),
          ),
          _buildMenuItem(
            icon: Icons.bar_chart,
            title: 'Analisis Financiero',
            onTap: () => _navegarA(
              context,
              ChangeNotifierProvider(
                create: (_) => GraficosViewModel(),
                child: GraficosScreen(idUsuario: idUsuario),
              ),
            ),
          ),
          Divider(color: AppTheme.blanco.withOpacity(0.3), height: 32),
          _buildMenuItem(
            icon: Icons.add_circle,
            title: 'Nueva transaccion',
            onTap: () => _navegarA(
                context, AddTransaccionesScreen(idUsuario: idUsuario)),
          ),
          _buildMenuItem(
            icon: Icons.add_chart,
            title: 'Nueva meta de ahorro',
            onTap: () => _navegarA(
                context, AddMetasAhorroScreen(idUsuario: idUsuario)),
          ),
          _buildMenuItem(
            icon: Icons.add_card,
            title: 'Nuevo presupuesto',
            onTap: () => _navegarA(
                context, AddPresupuestoScreen(idUsuario: idUsuario)),
          ),
          _buildMenuItem(
            icon: Icons.download,
            title: 'Exportar datos',
            onTap: () =>
                _navegarA(context, ExportarDatosScreen(idUsuario: idUsuario)),
          ),
        ],
      ),
    );
  }

  //construyo el menu con todos los items
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.naranja, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.blanco,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppTheme.gris,
      ),
    );
  }

  //metodo para navegar a una pantalla especifica
  void _navegarA(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}


