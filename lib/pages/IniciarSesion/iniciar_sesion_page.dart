import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tubilletera/components/custom_input.dart';
import 'package:tubilletera/services/auth_services.dart';
import 'package:tubilletera/services/migracion_service.dart';
import 'package:tubilletera/services/user_local_service.dart';
import 'package:tubilletera/theme/app_colors.dart';

class IniciarSesionPage extends StatefulWidget {
  const IniciarSesionPage({super.key});

  @override
  State<IniciarSesionPage> createState() => _IniciarSesionPageState();
}

class _IniciarSesionPageState extends State<IniciarSesionPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  final _authService = AuthService();
  final _migracionService = MigracionService();
  final _local = UserLocalService();

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    final profile = _local.getLoggedProfile();
    if (profile == null || !(profile['biometria'] ?? false)) return;

    final isAvailable = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();

    if (isAvailable && isSupported && FirebaseAuth.instance.currentUser != null) {
      final authenticated = await auth.authenticate(
        localizedReason: 'Autenticarse con biometría',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _handleLogin(Future<UserCredential> Function() action) async {
    try {
      await action();
      await _migracionService.migrarDatos();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }

  Future<void> login() async {
    await _handleLogin(() => _authService.loginUsuario(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        ));
  }

  Future<void> loginWithGoogle() async {
    await _handleLogin(_authService.loginConGoogle);
  }

  Future<void> loginWithBiometrics() async {
    final profile = _local.getLoggedProfile();
    if (profile == null || FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debés iniciar sesión manualmente una vez.')),
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
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticación fallida')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometría no disponible en este dispositivo')),
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
                        onPressed: loginWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                        ),
                        child: const Text("Ingresar con Google"),
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
