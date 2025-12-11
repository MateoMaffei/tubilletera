import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:tubilletera/components/custom_date_field.dart';
import 'package:tubilletera/components/custom_input.dart';
import 'package:tubilletera/model/ingreso_hive.dart';
import 'package:tubilletera/services/ingreso_services.dart';

class IngresosFormPage extends StatefulWidget {
  final Ingreso? ingreso;

  const IngresosFormPage({super.key, this.ingreso});

  @override
  State<IngresosFormPage> createState() => _IngresosFormPageState();
}

class _IngresosFormPageState extends State<IngresosFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final montoController = TextEditingController();
  final detallesController = TextEditingController();

  final ingresoService = IngresoService();

  DateTime? fechaVencimiento;
  bool estado = false;

  @override
  void initState() {
    super.initState();
    if (widget.ingreso != null) {
      final ing = widget.ingreso!;
      nombreController.text = ing.nombreDeudor;
      estado = ing.estado;
      fechaVencimiento = ing.fechaVencimiento;
      montoController.text =
          CurrencyInputFormatter(
                leadingSymbol: '\$ ',
                thousandSeparator: ThousandSeparator.Period,
                mantissaLength: 2,
              )
              .formatEditUpdate(
                const TextEditingValue(),
                TextEditingValue(text: ing.monto.toStringAsFixed(2)),
              )
              .text;
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaVencimiento ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'AR'),
    );

    if (picked != null) {
      setState(() => fechaVencimiento = picked);
    }
  }

  String limpiarMonto(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos obligatorios')),
      );
      return;
    }

    final nombre = nombreController.text.trim();
    final rawValue = limpiarMonto(montoController.text);
    final monto = double.tryParse(rawValue) ?? 0.0;

    if (widget.ingreso == null) {
      await ingresoService.crearIngreso(
        nombreDeudor: nombre,
        monto: monto,
        fechaVencimiento: fechaVencimiento!,
        estado: estado,
        descripcion: detallesController.text.trim()
      );
    } else {
      await ingresoService.actualizarIngreso(
        widget.ingreso!,
        nombreDeudor: nombre,
        monto: monto,
        fechaVencimiento: fechaVencimiento!,
        estado: estado,
        descripcion: detallesController.text.trim()
      );
    }

    if (mounted) Navigator.pop(context, widget.ingreso);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ingreso == null ? 'Nuevo Ingreso' : 'Editar Ingreso',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomInput(
                label: 'Nombre del deudor',
                controller: nombreController,
                prefixIcon: Icons.person,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              CustomInput(
                label: 'Monto',
                prefixIcon: Icons.money,
                controller: montoController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
                inputFormatters: [
                  CurrencyInputFormatter(
                    leadingSymbol: '\$ ',
                    useSymbolPadding: true,
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 2,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomDateField(
                label: 'Fecha de vencimiento',
                selectedDate: fechaVencimiento,
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Marcar como cobrado'),
                value: estado,
                onChanged: (value) => setState(() => estado = value),
              ),
              const SizedBox(height: 20),
              CustomInput(
                label: 'Detalles',
                controller: detallesController,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _guardar,
                label: const Text('Guardar ingreso'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
