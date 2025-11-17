import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tubilletera/services/auth_services.dart';
import 'package:tubilletera/services/user_local_service.dart';
import 'package:tubilletera/theme/app_colors.dart';

class BienvenidaPage extends StatefulWidget {
  const BienvenidaPage({super.key});

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String? loggedName;
  final _authService = AuthService();
  final _local = UserLocalService();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _verificarUsuarioLogueado();
  }

  void _loadUser() {
    final user = _local.getLoggedProfile();
    if (user != null) {
      setState(() {
        loggedName = user['nombre'];
      });
    }
  }

  Future<void> _verificarUsuarioLogueado() async {
    final loggedId = _local.loggedUserId;

    if (loggedId != null && FirebaseAuth.instance.currentUser != null) {
      final isAvailable = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();

      if (isAvailable && isSupported) {
        final authenticated = await auth.authenticate(
          localizedReason: 'Ingresar con biometría',
          options: const AuthenticationOptions(biometricOnly: true),
        );

        if (authenticated) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/LogoCompleto_NBG.png',
                height: 160,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Iniciar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (loggedName != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _authService.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text("No soy $loggedName"),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
