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
<<<<<<< HEAD
            title: 'Calculos',
            onTap: () => _navegarA(
=======
            title: 'Cálculos',
            onTap: () => _navigateTo(
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
              context,
              CalculosFinancierosScreen(idUsuario: idUsuario),
            ),
          ),
          _buildMenuItem(
            icon: Icons.bar_chart,
<<<<<<< HEAD
            title: 'Analisis Financiero',
            onTap: () => _navegarA(
=======
            title: 'Análisis Financiero',
            onTap: () => _navigateTo(
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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
<<<<<<< HEAD
            title: 'Nueva transaccion',
            onTap: () => _navegarA(
=======
            title: 'Nueva Transacción',
            onTap: () => _navigateTo(
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
                context, AddTransaccionesScreen(idUsuario: idUsuario)),
          ),
          _buildMenuItem(
            icon: Icons.add_chart,
<<<<<<< HEAD
            title: 'Nueva meta de ahorro',
            onTap: () => _navegarA(
=======
            title: 'Nueva Meta de Ahorro',
            onTap: () => _navigateTo(
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
                context, AddMetasAhorroScreen(idUsuario: idUsuario)),
          ),
          _buildMenuItem(
            icon: Icons.add_card,
<<<<<<< HEAD
            title: 'Nuevo presupuesto',
            onTap: () => _navegarA(
=======
            title: 'Nuevo Presupuesto',
            onTap: () => _navigateTo(
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
                context, AddPresupuestoScreen(idUsuario: idUsuario)),
          ),
          _buildMenuItem(
            icon: Icons.download,
<<<<<<< HEAD
            title: 'Exportar datos',
            onTap: () =>
                _navegarA(context, ExportarDatosScreen(idUsuario: idUsuario)),
=======
            title: 'Exportar Datos',
            onTap: () =>
                _navigateTo(context, ExportarDatosScreen(idUsuario: idUsuario)),
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  //construyo el menu con todos los items
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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

<<<<<<< HEAD
  //metodo para navegar a una pantalla especifica
  void _navegarA(BuildContext context, Widget screen) {
=======
  void _navigateTo(BuildContext context, Widget screen) {
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
<<<<<<< HEAD


=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
