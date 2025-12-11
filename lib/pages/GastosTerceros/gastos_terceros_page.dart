import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tubilletera/components/app_shell.dart';
import 'package:tubilletera/model/gasto_tercero_hive.dart';
import 'package:tubilletera/pages/GastosTerceros/gasto_tercero_form_page.dart';
import 'package:tubilletera/pages/GastosTerceros/gasto_tercero_detalle_page.dart';
import 'package:tubilletera/services/gasto_tercero_service.dart';
import 'package:tubilletera/theme/app_colors.dart';

class GastosTercerosPage extends StatefulWidget {
  const GastosTercerosPage({super.key});

  @override
  State<GastosTercerosPage> createState() => _GastosTercerosPageState();
}

class _GastosTercerosPageState extends State<GastosTercerosPage> {
  final service = GastoTerceroService();
  final formatPeso = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2);
  String? personaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final gastos = service.obtenerTodos();
    final personas = gastos.map((g) => g.persona).toSet().toList()..sort();
    final filtrados = personaSeleccionada == null
        ? gastos
        : gastos.where((g) => g.persona == personaSeleccionada).toList();
    final totalDebe = filtrados.fold<double>(0.0, (sum, g) {
      return sum + g.cuotas.where((c) => !c.pagada).fold(0.0, (s, c) => s + c.monto);
    });

    return AppShell(
      section: AppSection.terceros,
      title: 'Terceros',
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GastoTerceroFormPage()),
          );
          setState(() {});
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String?>(
              dropdownColor: AppColors.surface,
              iconEnabledColor: AppColors.textPrimary,
              style: const TextStyle(color: AppColors.textPrimary),
              isExpanded: true,
              value: personaSeleccionada,
              hint: const Text('Todas las personas'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...personas.map(
                  (p) => DropdownMenuItem(value: p, child: Text(p)),
                ),
              ],
              onChanged: (value) => setState(() => personaSeleccionada = value),
            ),
          ),
          if (personaSeleccionada != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Debe: ${formatPeso.format(totalDebe)}'),
              ),
            ),
          Expanded(
            child: filtrados.isEmpty
                ? const Center(child: Text('Sin registros'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtrados.length,
                    itemBuilder: (_, i) {
                      final g = filtrados[i];
                      return _buildCard(g);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(GastoTercero g) {
    final pagadas = g.cuotas.where((c) => c.pagada).length;
    final proxima = g.cuotas.firstWhereOrNull((c) => !c.pagada);
    final debe = g.cuotas
        .where((c) => !c.pagada)
        .fold<double>(0.0, (s, c) => s + c.monto);

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
            Text('Debe: ${formatPeso.format(debe)}'),
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
