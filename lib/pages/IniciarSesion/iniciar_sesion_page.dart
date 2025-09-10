import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tubilletera/components/custom_input.dart';
import 'package:tubilletera/theme/app_colors.dart';
import 'package:tubilletera/services/auth_services.dart';
import 'package:tubilletera/services/migracion_service.dart';

class IniciarSesionPage extends StatefulWidget {
  const IniciarSesionPage({super.key});

  @override
  State<IniciarSesionPage> createState() => _IniciarSesionPageState();
}

class _IniciarSesionPageState extends State<IniciarSesionPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  final authService = AuthService();
  final migracionService = MigracionService();

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    final box = Hive.box('usersBox');
    final storedEmail = box.get('email');
    final storedPassword = box.get('password');
    if (storedEmail == null || storedPassword == null) return;

    final isAvailable = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();

    if (isAvailable && isSupported) {
      final authenticated = await auth.authenticate(
        localizedReason: 'Autenticarse con biometría',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        try {
          await authService.loginUsuario(email: storedEmail, password: storedPassword);
          await migracionService.migrarDatos();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } catch (_) {}
      }
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      await authService.loginUsuario(email: email, password: password);
      final box = Hive.box('usersBox');
      await box.put('email', email);
      await box.put('password', password);
      await migracionService.migrarDatos();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email o contraseña incorrectos")),
      );
    }
  }

  Future<void> loginWithBiometrics() async {
    final box = Hive.box('usersBox');
    final email = box.get('email');
    final password = box.get('password');
    if (email == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero debés iniciar sesión manualmente una vez.")),
      );
      return;
    }

    final isAvailable = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();

    if (isAvailable && isSupported) {
      final authenticated = await auth.authenticate(
        localizedReason: 'Autenticarse con biometría',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        try {
          await authService.loginUsuario(email: email, password: password);
          await migracionService.migrarDatos();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Autenticación fallida")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Autenticación fallida")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometría no disponible en este dispositivo")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Image.asset(
                  'assets/LogoCompleto_NBG.png',
                  height: 200,
                ),
              ),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.primary),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CustomInput(
                        label: "Email",
                        controller: emailController,
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        label: "Contraseña",
                        controller: passwordController,
                        prefixIcon: Icons.lock,
                        keyboardType: TextInputType.visiblePassword,
                        maxLines: 1,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: login,
                        child: const Text("Ingresar"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: loginWithBiometrics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryButton,
                          foregroundColor: AppColors.secondaryButtonText,
                        ),
                        child: const Text("Ingresar con biometría"),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: const Text("¿No tenés cuenta? Registrate"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
