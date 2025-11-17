import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/ingreso_hive.dart';
import 'package:tubilletera/services/ingreso_services.dart';
import 'package:tubilletera/services/user_local_service.dart';
import 'package:tubilletera/theme/app_colors.dart';

import 'ingresos_form_page.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  final ingresoService = IngresoService();
  final formatPeso = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2);
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generarIngresosSueldo();
  }

  Future<void> _generarIngresosSueldo() async {
    final user = UserLocalService().getLoggedProfile();
    final sueldo = (user?['sueldo'] as num?)?.toDouble();
    if (sueldo == null) return;

    await ingresoService.asegurarIngresosSueldo(sueldo);
    if (mounted) setState(() {});
  }

  List<Ingreso> _ingresosDelMes() {
    final ingresos = ingresoService.obtenerPorMes(selectedDate.year, selectedDate.month);
    ingresos.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return ingresos;
  }

  void _confirmarCambioEstado(Ingreso ingreso) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ingreso.estado ? 'Marcar como pendiente' : 'Confirmar cobro'),
        content: Text(
          ingreso.estado
              ? '¿Deseás marcar este ingreso como pendiente nuevamente?'
              : '¿Confirmás que cobraste este ingreso?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ingresoService.marcarCobrado(ingreso, !ingreso.estado);
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(Ingreso ingreso) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: Text('¿Estás seguro de eliminar "${ingreso.nombreDeudor}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ingresoService.eliminarIngreso(ingreso.id);
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildIngresoCard(Ingreso ingreso) {
    final ahora = DateTime.now();
    final diasRestantes = ingreso.fechaVencimiento.difference(ahora).inDays;
    final estaVencido = diasRestantes < 0;

    Color estadoColor;
    String estadoTexto;

    if (ingreso.estado) {
      estadoColor = AppColors.abonadoText;
      estadoTexto = 'Cobrado';
    } else if (estaVencido) {
      estadoColor = AppColors.vencidoText;
      estadoTexto = 'Vencido';
    } else if (diasRestantes <= 5) {
      estadoColor = AppColors.porVencerText;
      estadoTexto = 'Por vencer';
    } else {
      estadoColor = AppColors.pendienteText;
      estadoTexto = 'Pendiente';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ingreso.nombreDeudor,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estadoTexto,
                    style: TextStyle(
                      fontSize: 12,
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) async {
                    switch (value) {
                      case 'editar':
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IngresosFormPage(ingreso: ingreso),
                          ),
                        );
                        setState(() {});
                        break;
                      case 'estado':
                        _confirmarCambioEstado(ingreso);
                        break;
                      case 'eliminar':
                        _confirmarEliminar(ingreso);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'estado',
                      child: Row(
                        children: [
                          Icon(
                            ingreso.estado ? Icons.undo : Icons.check_circle,
                            color: ingreso.estado ? Colors.orange : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ingreso.estado ? 'Marcar pendiente' : 'Marcar cobrado',
                            style: TextStyle(color: ingreso.estado ? Colors.orange : Colors.green),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.purple),
                          SizedBox(width: 8),
                          Text('Editar', style: TextStyle(color: Colors.purple)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vence: ${DateFormat('dd/MM/yyyy').format(ingreso.fechaVencimiento)}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  formatPeso.format(ingreso.monto),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: estadoColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingresos = _ingresosDelMes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos', style: TextStyle(color: AppColors.secondaryButtonText)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            color: AppColors.secondaryButtonText,
            onPressed: () async {
              final picked = await showMonthPicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
          )
        ],
      ),
      drawer: const MainDrawer(currentRoute: '/ingresos'),
      body: ingresos.isEmpty
          ? const Center(child: Text('No hay ingresos para este mes'))
          : ListView(
              children: ingresos.map(_buildIngresoCard).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<Ingreso?>(
            context,
            MaterialPageRoute(builder: (_) => const IngresosFormPage()),
          );
          setState(() {});
        },
        backgroundColor: AppColors.secondaryButton,
        child: const Icon(Icons.add),
      ),
    );
  }
}
