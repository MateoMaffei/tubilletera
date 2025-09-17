import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tubilletera/model/cuota_estado.dart';
import 'package:tubilletera/model/gasto_terceros.dart';

class GastoTerceroCard extends StatelessWidget {
  const GastoTerceroCard({
    super.key,
    required this.gasto,
    required this.onEditar,
    required this.onEliminar,
    required this.onToggleCuota,
  });

  final GastoTercero gasto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final void Function(String cuotaId, bool pagada) onToggleCuota;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_AR', symbol: '\$');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monto total: ${currency.format(gasto.montoTotal)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Cuotas: ${gasto.cantidadCuotas}'),
                      Text('Pagado: ${currency.format(gasto.totalPagado)}'),
                      Text('Pendiente: ${currency.format(gasto.totalPendiente)}'),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEditar();
                    } else if (value == 'delete') {
                      onEliminar();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
            const Divider(),
            Column(
              children: gasto.cuotas.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final cuota = entry.value;
                final fecha = cuota.fechaVencimiento;
                final fechaTexto = DateFormat('dd/MM/yyyy').format(fecha);
                final estadoTexto = cuota.estado == CuotaEstado.pagada
                    ? 'Pagada'
                    : cuota.estaVencida
                        ? 'Vencida'
                        : 'Pendiente';
                return CheckboxListTile(
                  value: cuota.estado == CuotaEstado.pagada,
                  onChanged: (value) => onToggleCuota(cuota.id, value ?? false),
                  title: Text('Cuota $index - ${currency.format(cuota.monto)}'),
                  subtitle: Text('Vence $fechaTexto · Estado: $estadoTexto'),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
