import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/cuota_hive.dart';
import 'package:tubilletera/services/deudor_services.dart';
import 'package:tubilletera/services/plan_cuotas_services.dart';
import 'package:tubilletera/theme/app_colors.dart';

import 'deudores_page.dart';
import 'plan_cuotas_form_page.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  final planService = PlanCuotasService();
  final deudorService = DeudorService();
  final formatPeso = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2);

  void _abrirFormulario({PlanCuotasDetalle? detalle}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanCuotasFormPage(plan: detalle?.plan),
      ),
    );
    if (mounted) setState(() {});
  }

  void _confirmarEliminarPlan(PlanCuotasDetalle detalle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar plan'),
        content: Text('¿Eliminar el plan "${detalle.plan.nombreGasto}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await planService.eliminarPlan(detalle.plan.id);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }

  Future<void> _registrarPagoCuota(Cuota cuota) async {
    await planService.marcarCuotaComoPagada(cuota, !cuota.pagada);
    if (mounted) setState(() {});
  }

  Widget _buildCuotasChips(List<Cuota> cuotas) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: cuotas
          .map(
            (c) => FilterChip(
              label: Text('C${c.numeroCuota} - ${DateFormat('dd/MM').format(c.fechaVencimiento)}'),
              selected: c.pagada,
              selectedColor: Colors.green.withOpacity(0.2),
              onSelected: (_) => _registrarPagoCuota(c),
              avatar: Icon(
                c.pagada ? Icons.check_circle : Icons.schedule,
                color: c.pagada ? Colors.green : Colors.orange,
                size: 18,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlanCard(PlanCuotasDetalle detalle) {
    final deudor = deudorService.obtenerPorId(detalle.plan.deudorId);
    final cuotasPendientes = detalle.cuotas.where((c) => !c.pagada).toList()
      ..sort((a, b) => a.numeroCuota.compareTo(b.numeroCuota));
    final proximaCuota = cuotasPendientes.isNotEmpty ? cuotasPendientes.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deudor?.nombre ?? 'Deudor', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(detalle.plan.nombreGasto, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'editar':
                      _abrirFormulario(detalle: detalle);
                      break;
                    case 'eliminar':
                      _confirmarEliminarPlan(detalle);
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'editar', child: Text('Editar plan')),
                  PopupMenuItem(value: 'eliminar', child: Text('Eliminar plan')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monto por cuota: ${formatPeso.format(detalle.montoCuota)}'),
              Text('Cuotas: ${detalle.cuotasPagadas}/${detalle.plan.cantidadTotalCuotas} pagadas'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cuotas adeudadas: ${detalle.cuotasAdeudadas}'),
              Text('Total adeudado: ${formatPeso.format(detalle.montoTotalAdeudado)}'),
            ],
          ),
          if (proximaCuota != null) ...[
            const SizedBox(height: 8),
            Text('Próxima cuota: ${DateFormat('dd/MM/yyyy').format(proximaCuota.fechaVencimiento)}'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _registrarPagoCuota(proximaCuota),
                icon: const Icon(Icons.payments_outlined),
                label: Text(proximaCuota.pagada ? 'Marcar como pendiente' : 'Registrar pago'),
              ),
            ),
          ],
          const Divider(),
          _buildCuotasChips(detalle.cuotas),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planes = planService.obtenerPlanesConCuotas();
    final totalCuotasAdeudadas = planes.fold<int>(0, (sum, p) => sum + p.cuotasAdeudadas);
    final totalMontoAdeudado =
        planes.fold<double>(0, (sum, p) => sum + p.montoTotalAdeudado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de cuotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const DeudoresPage()));
              if (mounted) setState(() {});
            },
          )
        ],
      ),
      drawer: const MainDrawer(currentRoute: '/ingresos'),
      body: planes.isEmpty
          ? const Center(child: Text('No hay planes cargados'))
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Resumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Cuotas adeudadas al día de hoy: $totalCuotasAdeudadas'),
                          Text('Monto total adeudado: ${formatPeso.format(totalMontoAdeudado)}'),
                        ],
                      ),
                    ),
                  ),
                ),
                ...planes.map(_buildPlanCard).toList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppColors.secondaryButton,
        child: const Icon(Icons.add),
      ),
    );
  }
}
