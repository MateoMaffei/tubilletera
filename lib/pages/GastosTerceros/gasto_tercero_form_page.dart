import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart' show ThousandSeparator;
import 'package:tubilletera/components/custom_date_field.dart';
import 'package:tubilletera/components/custom_input.dart';
import 'package:tubilletera/model/gasto_tercero_hive.dart';
import 'package:tubilletera/services/gasto_tercero_service.dart';

class GastoTerceroFormPage extends StatefulWidget {
  final GastoTercero? gasto;
  const GastoTerceroFormPage({super.key, this.gasto});

  @override
  State<GastoTerceroFormPage> createState() => _GastoTerceroFormPageState();
}

class _GastoTerceroFormPageState extends State<GastoTerceroFormPage> {
  final _formKey = GlobalKey<FormState>();
  final personaCtrl = TextEditingController();
  final montoCtrl = TextEditingController();
  final cuotasCtrl = TextEditingController();
  DateTime? primeraCuota;

  final service = GastoTerceroService();

  @override
  void initState() {
    super.initState();
    final g = widget.gasto;
    if (g != null) {
      personaCtrl.text = g.persona;
      montoCtrl.text = CurrencyInputFormatter(
        leadingSymbol: '\$ ',
        thousandSeparator: ThousandSeparator.Period,
        mantissaLength: 2,
      ).formatEditUpdate(const TextEditingValue(),
          TextEditingValue(text: g.montoTotal.toStringAsFixed(2))).text;
      cuotasCtrl.text = g.cantidadCuotas.toString();
      primeraCuota = g.cuotas.isNotEmpty ? g.cuotas.first.fechaVencimiento : DateTime.now();
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: primeraCuota ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'AR'),
    );
    if (picked != null) {
      setState(() => primeraCuota = picked);
    }
  }

  String limpiarMonto(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || primeraCuota == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos')),
      );
      return;
    }
    final persona = personaCtrl.text.trim();
    final monto = double.tryParse(limpiarMonto(montoCtrl.text)) ?? 0.0;
    final cuotas = int.tryParse(cuotasCtrl.text) ?? 1;

    if (widget.gasto == null) {
      await service.crear(
        persona: persona,
        montoTotal: monto,
        cantidadCuotas: cuotas,
        primeraCuota: primeraCuota!,
      );
    } else {
      await service.actualizar(
        widget.gasto!,
        persona: persona,
        montoTotal: monto,
        cantidadCuotas: cuotas,
        primeraCuota: primeraCuota!,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gasto == null ? 'Nuevo gasto de tercero' : 'Editar gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomInput(
                label: 'Persona',
                controller: personaCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              CustomInput(
                label: 'Monto total',
                controller: montoCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
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
              CustomInput(
                label: 'Cantidad de cuotas',
                controller: cuotasCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              CustomDateField(
                label: 'Primera fecha de vencimiento',
                selectedDate: primeraCuota,
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _guardar,
                label: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
