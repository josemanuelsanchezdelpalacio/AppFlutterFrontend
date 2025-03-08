import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_proyecto_app/screens/login_screen.dart';
import 'package:flutter_proyecto_app/screens/metas_ahorro_screen.dart';
import 'package:flutter_proyecto_app/screens/registro_screen.dart';
import 'package:flutter_proyecto_app/screens/home_screen.dart';
import 'package:flutter_proyecto_app/screens/presupuestos_screen.dart';
import 'package:flutter_proyecto_app/screens/add_transacciones_screen.dart';
import 'package:flutter_proyecto_app/screens/add_metas_ahorro_screen.dart';
import 'package:flutter_proyecto_app/screens/add_presupuestos_screen.dart';
import 'package:flutter_proyecto_app/screens/calculos_screen/calculos_screen.dart';
import 'package:flutter_proyecto_app/firebase_options.dart';
import 'package:flutter_proyecto_app/screens/transacciones_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:flutter_proyecto_app/models/metas_ahorro_viewmodel.dart';
import 'package:flutter_proyecto_app/models/presupuestos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/exportar_datos_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar la localización para español
  Intl.defaultLocale = 'es_ES';
  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación financiera',
      theme: AppTheme.obtenerTema(),
      initialRoute: '/login',
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return const Locale('es', 'ES');
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('es', 'ES');
      },
      onGenerateRoute: (settings) {
        int? userId;
        if (settings.arguments != null) {
          if (settings.arguments is int) {
            userId = settings.arguments as int;
          } else if (settings.arguments is Map && (settings.arguments as Map).containsKey('userId')) {
            final arg = (settings.arguments as Map)['idUsuario'];
            if (arg is int) {
              userId = arg;
            } else if (arg is String) {
              userId = int.tryParse(arg);
            }
          }
        }

        if (settings.name!.startsWith('/') && settings.name != '/login' && settings.name != '/register' && userId == null) {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        }

        final Map<String, Widget Function(BuildContext)> rutas = {
          '/home': (context) => HomeScreen(idUsuario: userId!),
          '/transacciones': (context) => TransaccionesScreen(idUsuario: userId!),
          '/metas': (context) => ChangeNotifierProvider(
                create: (context) => MetasAhorroViewModel(userId!),
                child: MetasAhorroScreen(idUsuario: userId!),
              ),
          '/presupuestos': (context) => ChangeNotifierProvider(
                create: (context) => PresupuestosViewModel(userId!),
                child: PresupuestosScreen(idUsuario: userId!),
              ),
          '/add-transaccion': (context) => AddTransactionScreen(idUsuario: userId!),
          '/add-meta': (context) => AddMetasAhorroScreen(idUsuario: userId!),
          '/add-presupuesto': (context) => AddPresupuestoScreen(idUsuario: userId!),
          '/calculos': (context) => CalculosFinancierosScreen(idUsuario: userId!),
          '/export-data': (context) => ExportarDatosScreen(idUsuario: userId!),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
        };

        if (rutas.containsKey(settings.name)) {
          return MaterialPageRoute(builder: rutas[settings.name]!);
        }
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
