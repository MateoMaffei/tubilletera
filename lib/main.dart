import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tubilletera/model/categoria_hive.dart';
import 'package:tubilletera/model/cuota_estado.dart';
import 'package:tubilletera/model/cuota_terceros.dart';
import 'package:tubilletera/model/gasto_hive.dart';
import 'package:tubilletera/model/gasto_terceros.dart';
import 'package:tubilletera/model/persona_terceros.dart';
import 'package:tubilletera/pages/Bienvenida/bienvenida_page.dart';
import 'package:tubilletera/pages/Categorias/categorias_page.dart';
import 'package:tubilletera/pages/Configuraciones/configuraciones_page.dart';
import 'package:tubilletera/pages/Gastos/gastos_page.dart';
import 'package:tubilletera/pages/GastosTerceros/gastos_terceros_page.dart';
import 'package:tubilletera/pages/Home/home_page.dart';
import 'package:tubilletera/pages/IniciarSesion/iniciar_sesion_page.dart';
import 'package:tubilletera/pages/Registrarse/registrarse_page.dart';
import 'package:tubilletera/pages/Splash/splash_page.dart';
import 'package:tubilletera/providers/third_party_expenses_provider.dart';
import 'package:tubilletera/services/third_party_expense_service.dart';
import 'package:tubilletera/services/third_party_person_service.dart';
import 'package:tubilletera/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('usersBox');

  _registerAdapters();

  await Hive.openBox<Categoria>('categoriasBox');
  await Hive.openBox<Gasto>('gastoBox');
  await Hive.openBox<PersonaTercero>(ThirdPartyPersonService.boxName);
  await Hive.openBox<GastoTercero>(ThirdPartyExpenseService.boxName);

  await initializeDateFormatting('es', 'AR');
  runApp(const _AppProviders());
}

void _registerAdapters() {
  try {
    Hive.registerAdapter(CategoriaAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(GastoAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(CuotaEstadoAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(CuotaTerceroAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(PersonaTerceroAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(GastoTerceroAdapter());
  } catch (_) {}
}

class _AppProviders extends StatelessWidget {
  const _AppProviders();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThirdPartyExpensesProvider()..cargarDatos(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es', 'AR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'AR'),
        Locale('en', 'US'),
      ],
      title: 'Login Demo',
      theme: AppTheme.light,
      initialRoute: '/splash',
      routes: {
        '/': (context) => const BienvenidaPage(),
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const IniciarSesionPage(),
        '/register': (context) => const RegistrarsePage(),
        '/home': (context) => const HomePage(),
        '/gastos': (context) => const GastosPage(),
        '/gastos-terceros': (context) => const GastosTercerosPage(),
        '/categorias': (context) => const CategoriasPage(),
        '/configuraciones': (context) => const ConfiguracionesPage(),
      },
    );
  }
}
