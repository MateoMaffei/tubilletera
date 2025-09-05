import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tubilletera/components/custom_input.dart';
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

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    final box = Hive.box('usersBox');
    final storedEmail = box.get('loggedUser');

    if (storedEmail != null) {
      final user = box.get(storedEmail);
      final usarBiometria = user?['biometria'] ?? false;

      if (!usarBiometria) return;

      final isAvailable = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();

      if (isAvailable && isSupported) {
        final authenticated = await auth.authenticate(
          localizedReason: 'Autenticarse con biometría',
          options: const AuthenticationOptions(biometricOnly: true),
        );

        if (authenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final box = Hive.box('usersBox');
    final user = box.get(email);

    if (user != null && user['password'] == password) {
      await box.put('loggedUser', email);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email o contraseña incorrectos")),
      );
    }
  }

  Future<void> loginWithBiometrics() async {
    final box = Hive.box('usersBox');
    final loggedEmail = box.get('loggedUser');
    if (loggedEmail == null) {
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
        Navigator.pushReplacementNamed(context, '/home');
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
