import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/models/metas_ahorro_viewmodel.dart';
import 'package:flutter_proyecto_app/models/presupuestos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/metas_ahorro_screen.dart';
import 'package:flutter_proyecto_app/screens/presupuestos_screen.dart';
import 'package:flutter_proyecto_app/screens/transacciones_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:flutter_proyecto_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int idUsuario;
  final int currentIndex;

  const CustomBottomNavBar({
    Key? key,
    required this.idUsuario,
    required this.currentIndex,
  }) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (currentIndex == index) return;

    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = HomeScreen(idUsuario: idUsuario);
        break;
      case 1:
        nextScreen = TransaccionesScreen(idUsuario: idUsuario);
        break;
      case 2:
        nextScreen = ChangeNotifierProvider(
          create: (context) => MetasAhorroViewModel(idUsuario),
          child: MetasAhorroScreen(idUsuario: idUsuario),
        );
        break;
      case 3:
        nextScreen = ChangeNotifierProvider(
          create: (context) => PresupuestosViewModel(idUsuario),
          child: PresupuestosScreen(idUsuario: idUsuario),
        );
        break;
      default:
        nextScreen = HomeScreen(idUsuario: idUsuario);
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          unselectedItemColor: Colors.grey,
          selectedItemColor: AppTheme.naranja,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_outlined),
              activeIcon: Icon(Icons.list),
              label: 'Transacciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              activeIcon: Icon(Icons.savings),
              label: 'Metas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Presupuestos',
            ),
          ],
          onTap: (index) => _onItemTapped(context, index),
        ),
      ),
    );
  }
}

