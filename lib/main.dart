import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tubilletera/model/categoria_hive.dart';
import 'package:tubilletera/model/gasto_hive.dart';
import 'package:tubilletera/model/ingreso_hive.dart';
import 'package:tubilletera/pages/Bienvenida/bienvenida_page.dart';
import 'package:tubilletera/pages/Categorias/categorias_page.dart';
import 'package:tubilletera/pages/Configuraciones/configuraciones_page.dart';
import 'package:tubilletera/pages/Gastos/gastos_page.dart';
import 'package:tubilletera/pages/GastosTerceros/gastos_terceros_page.dart';
import 'package:tubilletera/pages/Home/home_page.dart';
import 'package:tubilletera/pages/IniciarSesion/iniciar_sesion_page.dart';
import 'package:tubilletera/pages/Ingresos/ingresos_page.dart';
import 'package:tubilletera/pages/Registrarse/registrarse_page.dart';
import 'package:tubilletera/pages/Splash/splash_page.dart';
import 'package:tubilletera/services/ingreso_services.dart';
import 'package:tubilletera/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox('usersBox');

  Hive.registerAdapter(CategoriaAdapter());
  await Hive.openBox<Categoria>('categoriasBox');

  Hive.registerAdapter(GastoAdapter());
  await Hive.openBox<Gasto>('gastoBox');

  Hive.registerAdapter(IngresoAdapter());
  await Hive.openBox<Ingreso>('ingresoBox');

  await _asegurarSueldoInicial();

  await initializeDateFormatting('es', 'AR');
  runApp(const MyApp());
}

Future<void> _asegurarSueldoInicial() async {
  final usersBox = Hive.box('usersBox');
  final email = usersBox.get('loggedUser');
  if (email == null) return;

  final user = usersBox.get(email);
  final sueldo = (user?['sueldo'] as num?)?.toDouble();
  if (sueldo == null) return;

  final ingresoService = IngresoService();
  await ingresoService.asegurarIngresosSueldo(sueldo);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es','AR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'AR'), // Español (Argentina)
        Locale('en', 'US'), // Inglés
      ],
      title: 'Tu Billetera',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: '/splash',
        routes: {
          '/': (context) => const BienvenidaPage(),
          '/splash': (context) => const SplashPage(),
          '/login': (context) => const IniciarSesionPage(),
          '/register': (context) => const RegistrarsePage(),
          '/home': (context) => const HomePage(),
          '/ingresos': (context) => const IngresosPage(),
          '/gastos': (context) => const GastosPage(),
          '/gastos_terceros': (context) => const GastosTercerosPage(),
          '/categorias': (context) => const CategoriasPage(),
          '/configuraciones': (context) => const ConfiguracionesPage(),
        },
    );
  }
}
