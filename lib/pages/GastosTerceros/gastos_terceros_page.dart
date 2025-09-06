import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/gasto_tercero_hive.dart';
import 'package:tubilletera/pages/GastosTerceros/gasto_tercero_form_page.dart';
import 'package:tubilletera/pages/GastosTerceros/gasto_tercero_detalle_page.dart';
import 'package:tubilletera/services/gasto_tercero_service.dart';

class GastosTercerosPage extends StatefulWidget {
  const GastosTercerosPage({super.key});

  @override
  State<GastosTercerosPage> createState() => _GastosTercerosPageState();
}

class _GastosTercerosPageState extends State<GastosTercerosPage> {
  final service = GastoTerceroService();
  final formatPeso = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final gastos = service.obtenerTodos();

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos de terceros')),
      drawer: MainDrawer(currentRoute: '/gastos_terceros'),
      body: gastos.isEmpty
          ? const Center(child: Text('Sin registros'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gastos.length,
              itemBuilder: (_, i) {
                final g = gastos[i];
                return _buildCard(g);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GastoTerceroFormPage()),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(GastoTercero g) {
    final pagadas = g.cuotas.where((c) => c.pagada).length;
    final proxima = g.cuotas.firstWhereOrNull((c) => !c.pagada);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(g.persona),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cuotas: $pagadas/${g.cuotas.length}'),
            if (proxima != null)
              Text('Próxima: cuota ${proxima.numero} - '
                  '${DateFormat('dd/MM/yyyy').format(proxima.fechaVencimiento)}'),
            Text('Total: ${formatPeso.format(g.montoTotal)}'),
            Text('Por cuota: ${formatPeso.format(g.montoPorCuota)}'),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GastoTerceroDetallePage(gasto: g)),
          );
          setState(() {});
        },
      ),
    );
  }
}
