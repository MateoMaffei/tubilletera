import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tubilletera/services/auth_services.dart';
import 'package:tubilletera/services/migracion_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final _authService = AuthService();
  final _migracionService = MigracionService();
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _iniciarRecuperacionLegada();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _iniciarRecuperacionLegada() async {
    await Future.delayed(const Duration(seconds: 2));

    final recuperado = await _authService.recuperarUsuarioLocalConBiometria();
    if (recuperado) {
      await _migracionService.migrarDatos();
      final autenticado = await _solicitarBiometria();
      if (mounted && autenticado) {
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<bool> _solicitarBiometria() async {
    final disponible = await _localAuth.canCheckBiometrics;
    final soportado = await _localAuth.isDeviceSupported();

    if (!disponible || !soportado) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: 'Ingresá con tu biometría para continuar',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset('assets/LogoCompleto_NBG.png', height: 180),
        ),
      ),
    );
  }
}
