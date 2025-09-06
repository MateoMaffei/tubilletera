import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tubilletera/model/gasto_tercero_hive.dart';
import 'package:tubilletera/pages/GastosTerceros/gasto_tercero_form_page.dart';
import 'package:tubilletera/services/gasto_tercero_service.dart';

class GastoTerceroDetallePage extends StatefulWidget {
  final GastoTercero gasto;
  const GastoTerceroDetallePage({super.key, required this.gasto});

  @override
  State<GastoTerceroDetallePage> createState() => _GastoTerceroDetallePageState();
}

class _GastoTerceroDetallePageState extends State<GastoTerceroDetallePage> {
  final formatPeso = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2);
  final service = GastoTerceroService();

  void _editarFecha(CuotaTercero cuota) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: cuota.fechaVencimiento,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'AR'),
    );
    if (picked != null) {
      setState(() {
        cuota.fechaVencimiento = picked;
      });
      await widget.gasto.save();
    }
  }

  void _editarMonto(CuotaTercero cuota) async {
    final controller = TextEditingController(text: cuota.monto.toString());
    final monto = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar monto'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monto'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context, double.tryParse(controller.text));
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
    if (monto != null) {
      setState(() => cuota.monto = monto);
      await widget.gasto.save();
    }
  }

  void _togglePagada(CuotaTercero cuota, bool? value) async {
    setState(() => cuota.pagada = value ?? false);
    await widget.gasto.save();
  }

  Future<void> _editarGasto() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GastoTerceroFormPage(gasto: widget.gasto)),
    );
    setState(() {});
  }

  Future<void> _eliminarGasto() async {
    await service.eliminar(widget.gasto);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.gasto;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle - ${g.persona}'),
        actions: [
          IconButton(onPressed: _editarGasto, icon: const Icon(Icons.edit)),
          IconButton(onPressed: _eliminarGasto, icon: const Icon(Icons.delete)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('N°')),
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Monto')),
            DataColumn(label: Text('Pagada')),
          ],
          rows: g.cuotas.map((c) {
            return DataRow(
              cells: [
                DataCell(Text(c.numero.toString())),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(c.fechaVencimiento)),
                    onTap: () => _editarFecha(c)),
                DataCell(Text(formatPeso.format(c.monto)), onTap: () => _editarMonto(c)),
                DataCell(Checkbox(value: c.pagada, onChanged: (v) => _togglePagada(c, v))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
