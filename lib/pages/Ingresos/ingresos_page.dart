import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/cuota_hive.dart';
import 'package:tubilletera/model/ingreso_hive.dart';
import 'package:tubilletera/services/deudor_services.dart';
import 'package:tubilletera/services/ingreso_services.dart';
import 'package:tubilletera/services/plan_cuotas_services.dart';
import 'package:tubilletera/theme/app_colors.dart';

import 'deudores_page.dart';
import 'ingresos_form_page.dart';
import 'plan_cuotas_form_page.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  final planService = PlanCuotasService();
  final deudorService = DeudorService();
  final ingresoService = IngresoService();
  final formatPeso = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2);

  DateTime selectedMonth = DateTime.now();

  void _abrirPlanFormulario({PlanCuotasDetalle? detalle}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanCuotasFormPage(plan: detalle?.plan),
      ),
    );
    if (mounted) setState(() {});
  }

  void _abrirIngresoFormulario({Ingreso? ingreso}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IngresosFormPage(ingreso: ingreso),
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

  void _confirmarEliminarIngreso(Ingreso ingreso) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: Text('¿Eliminar el ingreso "${ingreso.nombreDeudor}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await ingresoService.eliminarIngreso(ingreso.id);
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

  Future<void> _toggleCobroIngreso(Ingreso ingreso) async {
    await ingresoService.marcarCobrado(ingreso, !ingreso.estado);
    if (mounted) setState(() {});
  }

  List<Ingreso> _ingresosDelMes() {
    final ingresos = ingresoService.obtenerPorMes(selectedMonth.year, selectedMonth.month);
    ingresos.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return ingresos;
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
                      _abrirPlanFormulario(detalle: detalle);
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

  Widget _buildPlanesTab() {
    final planes = planService.obtenerPlanesConCuotas();
    final totalCuotasAdeudadas = planes.fold<int>(0, (sum, p) => sum + p.cuotasAdeudadas);
    final totalMontoAdeudado = planes.fold<double>(0, (sum, p) => sum + p.montoTotalAdeudado);

    if (planes.isEmpty) {
      return const Center(child: Text('No hay planes cargados'));
    }

    return ListView(
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
    );
  }

  Widget _buildIngresoTile(Ingreso ingreso) {
    final fecha = DateFormat('dd/MM/yyyy').format(ingreso.fechaVencimiento);
    return ListTile(
      leading: Checkbox(
        value: ingreso.estado,
        onChanged: (_) => _toggleCobroIngreso(ingreso),
      ),
      title: Text(ingreso.nombreDeudor, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vence: $fecha'),
          Text(ingreso.estado ? 'Cobrado' : 'Pendiente',
              style: TextStyle(color: ingreso.estado ? Colors.green : Colors.orange)),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(formatPeso.format(ingreso.monto), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'editar':
                  _abrirIngresoFormulario(ingreso: ingreso);
                  break;
                case 'eliminar':
                  _confirmarEliminarIngreso(ingreso);
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'editar', child: Text('Editar')),
              PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
      onTap: () => _toggleCobroIngreso(ingreso),
      onLongPress: () => _confirmarEliminarIngreso(ingreso),
    );
  }

  Widget _buildIngresosTab() {
    final ingresos = _ingresosDelMes();
    final total = ingresos.fold<double>(0, (sum, i) => sum + i.monto);
    final cobrados = ingresos.where((i) => i.estado).fold<double>(0, (sum, i) => sum + i.monto);
    final pendientes = total - cobrados;

    final ingresosPorDeudor = <String, List<Ingreso>>{};
    for (final ingreso in ingresos) {
      ingresosPorDeudor.putIfAbsent(ingreso.nombreDeudor, () => []).add(ingreso);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              final picked = await showMonthPicker(
                context: context,
                initialDate: selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(DateTime.now().year + 1),
              );
              if (picked != null) setState(() => selectedMonth = picked);
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(DateFormat.yMMMM('es_AR').format(selectedMonth),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        Card(
          color: AppColors.primaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resumen de ingresos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Total del mes: ${formatPeso.format(total)}'),
                Text('Cobrado: ${formatPeso.format(cobrados)}'),
                Text('Pendiente: ${formatPeso.format(pendientes)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (ingresos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No hay ingresos registrados para este mes')),
          )
        else
          ...ingresosPorDeudor.entries.map((entry) {
            final ingresosDeudor = entry.value..sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
            final totalDeudor = ingresosDeudor.fold<double>(0, (sum, i) => sum + i.monto);
            final cobradosDeudor = ingresosDeudor.where((i) => i.estado).fold<double>(0, (sum, i) => sum + i.monto);
            final pendientesDeudor = totalDeudor - cobradosDeudor;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Total: ${formatPeso.format(totalDeudor)}  |  Cobrado: ${formatPeso.format(cobradosDeudor)}  |  Pendiente: ${formatPeso.format(pendientesDeudor)}',
                  style: const TextStyle(fontSize: 12),
                ),
                children: ingresosDeudor
                    .map((ingreso) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildIngresoTile(ingreso),
                        ))
                    .toList(),
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(builder: (context) {
        final tabController = DefaultTabController.of(context)!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ingresos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.people_outline),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const DeudoresPage()));
                  if (mounted) setState(() {});
                },
              )
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Ingresos'),
                Tab(text: 'Planes de cuotas'),
              ],
            ),
          ),
          drawer: const MainDrawer(currentRoute: '/ingresos'),
          body: TabBarView(
            children: [
              // Ingresos simples
              _buildIngresosTab(),
              // Planes de cuotas
              _buildPlanesTab(),
            ],
          ),
          floatingActionButton: AnimatedBuilder(
            animation: tabController,
            builder: (context, _) {
              final esTabIngresos = tabController.index == 0;
              return FloatingActionButton(
                onPressed: esTabIngresos ? _abrirIngresoFormulario : _abrirPlanFormulario,
                backgroundColor: AppColors.secondaryButton,
                child: Icon(esTabIngresos ? Icons.add : Icons.playlist_add),
              );
            },
          ),
        );
      }),
    );
  }
}
