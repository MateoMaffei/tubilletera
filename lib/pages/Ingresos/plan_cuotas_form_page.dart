import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:intl/intl.dart';
import 'package:tubilletera/components/custom_date_field.dart';
import 'package:tubilletera/components/custom_input.dart';
import 'package:tubilletera/model/plan_cuotas_hive.dart';
import 'package:tubilletera/services/deudor_services.dart';
import 'package:tubilletera/services/plan_cuotas_services.dart';

class PlanCuotasFormPage extends StatefulWidget {
  final PlanCuotas? plan;

  const PlanCuotasFormPage({super.key, this.plan});

  @override
  State<PlanCuotasFormPage> createState() => _PlanCuotasFormPageState();
}

class _PlanCuotasFormPageState extends State<PlanCuotasFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreGastoController = TextEditingController();
  final _montoTotalController = TextEditingController();
  final _cantidadCuotasController = TextEditingController();
  final _cuotasPagadasController = TextEditingController();

  final _deudorService = DeudorService();
  final _planService = PlanCuotasService();

  String? _deudorSeleccionado;
  DateTime? _fechaInicio;

  @override
  void initState() {
    super.initState();
    if (widget.plan != null) {
      final plan = widget.plan!;
      _deudorSeleccionado = plan.deudorId;
      _nombreGastoController.text = plan.nombreGasto;
      _montoTotalController.text = plan.montoTotal.toStringAsFixed(2);
      _cantidadCuotasController.text = plan.cantidadTotalCuotas.toString();
      _cuotasPagadasController.text = plan.cuotasPagadasIniciales.toString();
      _fechaInicio = plan.fechaInicio;
    }
  }

  String _limpiarMonto(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _fechaInicio == null || _deudorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos obligatorios')),
      );
      return;
    }

    final monto = double.tryParse(_limpiarMonto(_montoTotalController.text)) ?? 0;
    final cantidadCuotas = int.tryParse(_cantidadCuotasController.text) ?? 1;
    final cuotasPagadasRaw = int.tryParse(_cuotasPagadasController.text) ?? 0;
    final cuotasPagadas = cuotasPagadasRaw.clamp(0, cantidadCuotas);

    if (widget.plan == null) {
      await _planService.crearPlan(
        deudorId: _deudorSeleccionado!,
        nombreGasto: _nombreGastoController.text.trim(),
        montoTotal: monto,
        cantidadTotalCuotas: cantidadCuotas,
        fechaInicio: _fechaInicio!,
        cuotasPagadasIniciales: cuotasPagadas,
      );
    } else {
      await _planService.actualizarPlan(
        widget.plan!,
        deudorId: _deudorSeleccionado!,
        nombreGasto: _nombreGastoController.text.trim(),
        montoTotal: monto,
        cantidadTotalCuotas: cantidadCuotas,
        fechaInicio: _fechaInicio!,
        cuotasPagadasIniciales: cuotasPagadas,
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final deudores = _deudorService.obtenerTodos();
    final format = NumberFormat.currency(locale: 'es_AR', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan == null ? 'Nuevo plan de cuotas' : 'Editar plan de cuotas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _deudorSeleccionado,
                decoration: const InputDecoration(labelText: 'Deudor'),
                items: deudores
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(d.nombre),
                      ),
                    )
                    .toList(),
                validator: (v) => v == null ? 'Seleccioná un deudor' : null,
                onChanged: (value) => setState(() => _deudorSeleccionado = value),
              ),
              const SizedBox(height: 12),
              CustomInput(
                label: 'Nombre del gasto',
                controller: _nombreGastoController,
                prefixIcon: Icons.shopping_bag_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              CustomInput(
                label: 'Monto total',
                controller: _montoTotalController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.monetization_on_outlined,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      label: 'Cantidad total de cuotas',
                      controller: _cantidadCuotasController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.numbers,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInput(
                      label: 'Cuotas ya pagadas (opcional)',
                      controller: _cuotasPagadasController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.done_all,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomDateField(
                label: 'Fecha de inicio',
                selectedDate: _fechaInicio,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaInicio ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es', 'AR'),
                  );
                  if (picked != null) setState(() => _fechaInicio = picked);
                },
              ),
              const SizedBox(height: 12),
              if (_cantidadCuotasController.text.isNotEmpty && _montoTotalController.text.isNotEmpty)
                Builder(builder: (_) {
                  final monto = double.tryParse(_limpiarMonto(_montoTotalController.text)) ?? 0;
                  final cuotas = int.tryParse(_cantidadCuotasController.text) ?? 1;
                  final montoCuota = monto / (cuotas == 0 ? 1 : cuotas);
                  return Text('Monto estimado por cuota: ${format.format(montoCuota)}');
                }),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _guardar,
                label: const Text('Guardar plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
