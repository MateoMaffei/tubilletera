import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tubilletera/model/gasto_terceros.dart';
import 'package:tubilletera/model/persona_terceros.dart';
import 'package:tubilletera/pages/GastosTerceros/persona_tercero_form_page.dart';
import 'package:tubilletera/providers/third_party_expenses_provider.dart';

class GastoTerceroFormPage extends StatefulWidget {
  const GastoTerceroFormPage({
    super.key,
    this.personaPreseleccionada,
    this.gasto,
  });

  final PersonaTercero? personaPreseleccionada;
  final GastoTercero? gasto;

  @override
  State<GastoTerceroFormPage> createState() => _GastoTerceroFormPageState();
}

class _GastoTerceroFormPageState extends State<GastoTerceroFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montoTotalController;
  late final TextEditingController _montoCuotaController;
  late final TextEditingController _cantidadCuotasController;
  DateTime? _fechaVencimiento;
  int _modo = 0; // 0 = total, 1 = monto por cuota
  String? _personaId;

  @override
  void initState() {
    super.initState();
    final gasto = widget.gasto;
    _montoTotalController = TextEditingController(
      text: gasto != null ? gasto.montoTotal.toStringAsFixed(2) : '',
    );
    _montoCuotaController = TextEditingController(
      text: gasto != null && gasto.cuotas.isNotEmpty
          ? gasto.cuotas.first.monto.toStringAsFixed(2)
          : '',
    );
    _cantidadCuotasController = TextEditingController(
      text: gasto != null ? gasto.cantidadCuotas.toString() : '',
    );
    _fechaVencimiento = gasto?.fechaPrimerVencimiento;
    _personaId = gasto?.personaId ?? widget.personaPreseleccionada?.id;
  }

  @override
  void dispose() {
    _montoTotalController.dispose();
    _montoCuotaController.dispose();
    _cantidadCuotasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThirdPartyExpensesProvider>();
    final personas = provider.personas;
    final moneda = NumberFormat.currency(locale: 'es_AR', symbol: '\$');
    final fechaTexto = _fechaVencimiento == null
        ? 'Seleccionar fecha'
        : DateFormat('dd/MM/yyyy').format(_fechaVencimiento!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gasto == null ? 'Nuevo gasto' : 'Editar gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _personaId,
                decoration: const InputDecoration(labelText: 'Persona'),
                items: personas
                    .map(
                      (persona) => DropdownMenuItem(
                        value: persona.id,
                        child: Text(persona.nombreCompleto),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _personaId = value),
                validator: (value) => value == null ? 'Seleccione una persona' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PersonaTerceroFormPage(),
                      ),
                    );
                    if (mounted) {
                      context.read<ThirdPartyExpensesProvider>().cargarDatos();
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('Nueva persona'),
                ),
              ),
              const SizedBox(height: 12),
              ToggleButtons(
                isSelected: [_modo == 0, _modo == 1],
                onPressed: (index) => setState(() => _modo = index),
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Monto total'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Monto por cuota'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_modo == 0)
                TextFormField(
                  controller: _montoTotalController,
                  decoration: InputDecoration(labelText: 'Monto total (${moneda.currencySymbol})'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validarMonto,
                )
              else
                TextFormField(
                  controller: _montoCuotaController,
                  decoration: InputDecoration(labelText: 'Monto por cuota (${moneda.currencySymbol})'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validarMonto,
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cantidadCuotasController,
                decoration: const InputDecoration(labelText: 'Cantidad de cuotas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la cantidad de cuotas';
                  }
                  final numero = int.tryParse(value);
                  if (numero == null || numero <= 0) {
                    return 'La cantidad debe ser mayor a cero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha primer vencimiento'),
                subtitle: Text(fechaTexto),
                trailing: const Icon(Icons.calendar_today),
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 16),
              if (_modo == 0 && _cantidadCuotasController.text.isNotEmpty && _montoTotalController.text.isNotEmpty)
                Text(
                  'Monto por cuota estimado: ${_calcularMontoCuotaDesdeTotal(moneda)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (_modo == 1 && _cantidadCuotasController.text.isNotEmpty && _montoCuotaController.text.isNotEmpty)
                Text(
                  'Monto total estimado: ${_calcularTotalDesdeCuota(moneda)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validarMonto(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese un monto válido';
    }
    final monto = double.tryParse(value.replaceAll(',', '.'));
    if (monto == null || monto <= 0) {
      return 'El monto debe ser mayor a cero';
    }
    return null;
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? ahora,
      firstDate: DateTime(ahora.year - 1),
      lastDate: DateTime(ahora.year + 5),
    );
    if (seleccionada != null) {
      setState(() => _fechaVencimiento = seleccionada);
    }
  }

  String _calcularMontoCuotaDesdeTotal(NumberFormat moneda) {
    final total = double.tryParse(_montoTotalController.text.replaceAll(',', '.')) ?? 0;
    final cuotas = int.tryParse(_cantidadCuotasController.text) ?? 1;
    if (cuotas == 0) return moneda.format(0);
    return moneda.format(total / cuotas);
  }

  String _calcularTotalDesdeCuota(NumberFormat moneda) {
    final cuota = double.tryParse(_montoCuotaController.text.replaceAll(',', '.')) ?? 0;
    final cuotas = int.tryParse(_cantidadCuotasController.text) ?? 1;
    return moneda.format(cuota * cuotas);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione la fecha del primer vencimiento')),
      );
      return;
    }
    final provider = context.read<ThirdPartyExpensesProvider>();
    final cuotas = int.parse(_cantidadCuotasController.text);
    final personaId = _personaId;
    if (personaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una persona')),
      );
      return;
    }

    double montoTotal;
    double? montoPorCuota;
    if (_modo == 0) {
      montoTotal = double.parse(_montoTotalController.text.replaceAll(',', '.'));
      montoPorCuota = null;
    } else {
      montoPorCuota = double.parse(_montoCuotaController.text.replaceAll(',', '.'));
      montoTotal = montoPorCuota * cuotas;
    }

    try {
      await provider.registrarGasto(
        id: widget.gasto?.id,
        personaId: personaId,
        montoTotal: montoTotal,
        cantidadCuotas: cuotas,
        fechaPrimerVencimiento: _fechaVencimiento!,
        montoPorCuota: montoPorCuota,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el gasto: ${e.toString()}')),
      );
    }
  }
}
