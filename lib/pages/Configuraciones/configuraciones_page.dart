import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:tubilletera/components/custom_date_field.dart';
import 'package:tubilletera/components/custom_input.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/services/auth_services.dart';
import 'package:tubilletera/services/user_local_service.dart';

class ConfiguracionesPage extends StatefulWidget {
  const ConfiguracionesPage({super.key});

  @override
  State<ConfiguracionesPage> createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final emailController = TextEditingController();
  final sueldoController = TextEditingController();
  DateTime? fechaNacimiento;
  bool usarBiometria = false;

  final _authService = AuthService();
  final _local = UserLocalService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final user = _local.getLoggedProfile();
    if (user != null) {
      emailController.text = user['email'] ?? '';
      nombreController.text = user['nombre'] ?? '';
      apellidoController.text = user['apellido'] ?? '';
      final sueldoRaw = user['sueldo'];

      if (sueldoRaw != null) {
        sueldoController.text = CurrencyInputFormatter(
          leadingSymbol: '\$ ',
          thousandSeparator: ThousandSeparator.Period,
          mantissaLength: 2,
        ).formatEditUpdate(
          const TextEditingValue(),
          TextEditingValue(text: (sueldoRaw as num).toDouble().toStringAsFixed(2)),
        ).text;
      } else {
        sueldoController.text = '';
      }

      usarBiometria = user['biometria'] ?? false;
      if (user['fechaNacimiento'] != null) {
        fechaNacimiento = DateTime.tryParse(user['fechaNacimiento']);
      }
      setState(() {});
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'AR'),
    );
    if (picked != null) {
      setState(() => fechaNacimiento = picked);
    }
  }

  void _guardarCambios() async {
    final sueldoLimpio = sueldoController.text
        .replaceAll(RegExp(r'[^\d,]'), '')
        .replaceAll(',', '.');

    final sueldoParsed = sueldoLimpio.isNotEmpty ? double.tryParse(sueldoLimpio) : null;

    if (sueldoParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El sueldo ingresado no es válido.")),
      );
      return;
    }

    await _authService.actualizarPerfil(
      nombre: nombreController.text.trim(),
      apellido: apellidoController.text.trim(),
      fechaNacimiento: fechaNacimiento,
      sueldo: sueldoParsed,
    );

    await _authService.actualizarBiometria(usarBiometria);
    await _authService.obtenerDatosUsuario();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos actualizados correctamente.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final iniciales = "${nombreController.text.isNotEmpty ? nombreController.text[0] : ''}${apellidoController.text.isNotEmpty ? apellidoController.text[0] : ''}";

    return Scaffold(
      appBar: AppBar(title: const Text("Configuraciones")),
      drawer: MainDrawer(currentRoute: '/configuraciones'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade700,
                child: Text(
                  iniciales.toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomInput(label: "Nombre", controller: nombreController, enable: false),
            const SizedBox(height: 10),
            CustomInput(label: "Apellido", controller: apellidoController, enable: false),
            const SizedBox(height: 10),
            CustomInput(label: "Email", controller: emailController, enable: false),
            const SizedBox(height: 10),
            CustomDateField(
              label: "Fecha de nacimiento",
              selectedDate: fechaNacimiento,
              onTap: _seleccionarFecha,
            ),
            const SizedBox(height: 10),
            CustomInput(
              label: "Sueldo mensual",
              controller: sueldoController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyInputFormatter(
                  leadingSymbol: '\$ ',
                  useSymbolPadding: true,
                  thousandSeparator: ThousandSeparator.Period,
                  mantissaLength: 2,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Autenticación por biometría"),
              value: usarBiometria,
              onChanged: (val) => setState(() => usarBiometria = val),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              onPressed: _guardarCambios,
              label: const Text("Guardar cambios"),
            )
          ],
        ),
      ),
    );
  }
}
