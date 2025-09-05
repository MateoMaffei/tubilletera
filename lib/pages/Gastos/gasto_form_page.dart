import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart' show ThousandSeparator;
import 'package:tubilletera/components/custom_date_field.dart';
import 'package:tubilletera/components/custom_input.dart';
import 'package:tubilletera/model/gasto_hive.dart';
import 'package:tubilletera/services/categoria_services.dart';
import 'package:tubilletera/services/gasto_services.dart';

class GastoFormPage extends StatefulWidget {
  final Gasto? gasto;

  const GastoFormPage({super.key, this.gasto});

  @override
  State<GastoFormPage> createState() => _GastoFormPageState();
}

class _GastoFormPageState extends State<GastoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final descripcionController = TextEditingController();
  final montoController = TextEditingController();
  final detallesController = TextEditingController();

  final gastoService = GastoService();
  final categoriaService = CategoriaService();

  String? categoriaSeleccionada;
  DateTime? fechaVencimiento;

  @override
  void initState() {
    super.initState();
    if (widget.gasto != null) {
      final g = widget.gasto!;
      descripcionController.text = g.descripcion;
      detallesController.text = g.detalles ?? '';
      categoriaSeleccionada = g.idCategoria;
      fechaVencimiento = g.fechaVencimiento;
      montoController.text = CurrencyInputFormatter(
        leadingSymbol: '\$ ',
        thousandSeparator: ThousandSeparator.Period,
        mantissaLength: 2,
      ).formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: g.monto.toStringAsFixed(2)),
      ).text;
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaVencimiento ?? DateTime.now(),
      
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'AR')
    );

    if (picked != null) {
      setState(() => fechaVencimiento = picked);
    }
  }

  String limpiarMonto(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || categoriaSeleccionada == null || fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos obligatorios')),
      );
      return;
    }

    final descripcion = descripcionController.text.trim();
    final rawValue = limpiarMonto(montoController.text);
    final monto = double.tryParse(rawValue) ?? 0.0;
    final detalles = detallesController.text.trim().isEmpty ? null : detallesController.text.trim();

    if (widget.gasto == null) {
      await gastoService.crearGasto(
        descripcion: descripcion,
        idCategoria: categoriaSeleccionada!,
        monto: monto,
        fechaVencimiento: fechaVencimiento!,
        detalles: detalles,
      );
    } else {
      await gastoService.actualizarGasto(
        widget.gasto!,
        descripcion: descripcion,
        idCategoria: categoriaSeleccionada!,
        monto: monto,
        fechaVencimiento: fechaVencimiento!,
        detalles: detalles,
        estado: widget.gasto!.estado
      );
    }

    if (mounted) Navigator.pop(context, widget.gasto);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = categoriaService.obtenerTodas();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gasto == null ? 'Nuevo Gasto' : 'Editar Gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomInput(
                label: 'Descripción',
                prefixIcon: Icons.abc,
                controller: descripcionController,
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 10),
              CustomInput(
                label: 'Monto',
                prefixIcon: Icons.money,
                controller: montoController,
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
              DropdownButtonFormField<String>(
                value: categoriaSeleccionada,
                decoration: CustomInput.decoration(label: 'Categoría', icon: Icons.category),
                items: categorias
                    .map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.descripcion)))
                    .toList(),
                onChanged: (value) => setState(() => categoriaSeleccionada = value),
                validator: (v) => v == null ? 'Seleccioná una categoría' : null,
              ),
              const SizedBox(height: 10),
              CustomDateField(
                label: 'Fecha de vencimiento',
                selectedDate: fechaVencimiento,
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 10),
              CustomInput(
                label: 'Detalles',
                controller: detallesController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _guardar,
                label: const Text('Guardar gasto'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
