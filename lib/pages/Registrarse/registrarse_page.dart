import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tubilletera/components/custom_date_field.dart';
import 'package:tubilletera/components/custom_input.dart';
import 'package:tubilletera/theme/app_colors.dart';

class RegistrarsePage extends StatefulWidget {
  const RegistrarsePage({super.key});

  @override
  State<RegistrarsePage> createState() => _RegistrarsePageState();
}

class _RegistrarsePageState extends State<RegistrarsePage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final repeatPassController = TextEditingController();
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final sueldoController = TextEditingController();
  DateTime? fechaNacimiento;

  final _formKey = GlobalKey<FormState>();

  void register() async {
    final box = Hive.box('usersBox');
    final email = emailController.text.trim();
    final pass = passController.text.trim();
    final repeat = repeatPassController.text.trim();
    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final sueldo = sueldoController.text.isNotEmpty
        ? double.tryParse(sueldoController.text.trim())
        : null;

    if (pass != repeat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    if (box.containsKey(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El email ya está registrado")),
      );
      return;
    }

    await box.put(email, {
      'password': pass,
      'nombre': nombre,
      'apellido': apellido,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'sueldo': sueldo
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registro exitoso")),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'AR'),
    );
    if (picked != null) {
      setState(() => fechaNacimiento = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Crear cuenta"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset(
                'assets/LogoSinEslogan_NBG.png',
                height: 150,
              ),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.primary),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomInput(label: "Nombre", controller: nombreController, prefixIcon: Icons.person),
                        const SizedBox(height: 16),
                        CustomInput(label: "Apellido", controller: apellidoController, prefixIcon: Icons.person_outline),
                        const SizedBox(height: 16),
                        CustomDateField(
                          label: "Fecha de nacimiento",
                          selectedDate: fechaNacimiento,
                          onTap: pickDate,
                        ),
                        const SizedBox(height: 16),
                        CustomInput(label: "Email", controller: emailController, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email),
                        const SizedBox(height: 16),
                        CustomInput(label: "Contraseña", controller: passController, prefixIcon: Icons.lock, keyboardType: TextInputType.visiblePassword, obscureText: true),
                        const SizedBox(height: 16),
                        CustomInput(label: "Repetir Contraseña", controller: repeatPassController, prefixIcon: Icons.lock_outline, keyboardType: TextInputType.visiblePassword, obscureText: true),
                        const SizedBox(height: 16),
                        CustomInput(label: "Sueldo (opcional)", controller: sueldoController, keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
                        const SizedBox(height: 24),
                        ElevatedButton(onPressed: register, child: const Text("Registrarse")),
                      ],
                    ),
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
