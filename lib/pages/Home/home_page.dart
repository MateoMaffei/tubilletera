// Asegurate de tener estas importaciones
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/gasto_hive.dart';
import 'package:tubilletera/model/categoria_hive.dart';
import 'package:tubilletera/model/ingreso_hive.dart';
import 'package:tubilletera/services/user_local_service.dart';
import 'package:tubilletera/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final gastosBox = Hive.box<Gasto>('gastoBox');
    final categoriasBox = Hive.box<Categoria>('categoriasBox');
    final ingresosBox = Hive.box<Ingreso>('ingresoBox');
    final user = UserLocalService().getLoggedProfile();
    final sueldo = user?['sueldo'] ?? 0.0;

    final formatPeso = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 2);

    final todosLosGastos = gastosBox.values.where((g) =>
      g.fechaVencimiento.month == selectedMonth.month &&
      g.fechaVencimiento.year == selectedMonth.year).toList();

    final ingresosDelMes = ingresosBox.values.where((ing) =>
      ing.fechaVencimiento.month == selectedMonth.month &&
      ing.fechaVencimiento.year == selectedMonth.year).toList();

    final totalGastado = todosLosGastos.fold<double>(0.0, (sum, g) => sum + g.monto);
    final totalPagado = todosLosGastos.where((g) => g.estado).fold<double>(0.0, (sum, g) => sum + g.monto);
    final restantePagar = totalGastado - totalPagado;
    final totalIngresos = ingresosDelMes.fold<double>(0.0, (sum, ing) => sum + ing.monto);
    final cobrados = ingresosDelMes.where((ing) => ing.estado).fold<double>(0.0, (sum, ing) => sum + ing.monto);
    final baseIngresos = totalIngresos > 0 ? totalIngresos : sueldo;
    final disponible = baseIngresos - totalGastado;

    final gastosPorCategoria = <String, double>{};
    for (final gasto in todosLosGastos) {
      gastosPorCategoria[gasto.idCategoria] = (gastosPorCategoria[gasto.idCategoria] ?? 0) + gasto.monto;
    }

    final categorias = Map.fromEntries(
      categoriasBox.values.map((c) => MapEntry(c.id, c.descripcion)),
    );

    final hoy = DateTime.now();
    final proximosGastos = todosLosGastos
        .where((g) => !g.estado && g.fechaVencimiento.difference(hoy).inDays <= 5 && g.fechaVencimiento.isAfter(hoy))
        .toList()
      ..sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));

    final porcentaje = (totalGastado / (baseIngresos == 0 ? 1 : baseIngresos)) * 100;
    final alertas = <String>[];

    if (disponible < 0) {
      alertas.add('Tus gastos del mes superan tus ingresos disponibles en ${formatPeso.format(disponible.abs())}. Bajá compras discrecionales hasta equilibrar.');
    } else if (porcentaje > 80) {
      alertas.add('Llevás usado ${porcentaje.toStringAsFixed(1)}% de tus ingresos: recorta gastos variables antes de fin de mes.');
    }

    if (gastosPorCategoria.isNotEmpty) {
      final entry = gastosPorCategoria.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final descripcion = categorias[entry.key] ?? 'Categoría principal';
      final share = (entry.value / (totalGastado == 0 ? 1 : totalGastado)) * 100;
      if (share > 35) {
        alertas.add('El ${share.toStringAsFixed(1)}% de tus gastos está en "$descripcion". Revisá ahí para liberar presupuesto.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      drawer: MainDrawer(currentRoute: '/home'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  if (picked != null) {
                    setState(() => selectedMonth = picked);
                  }
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  DateFormat.yMMMM('es_AR').format(selectedMonth),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alertas y recomendaciones',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (alertas.isEmpty)
                      const Text('Todo en orden por ahora. Seguimos monitoreando tus gastos.')
                    else
                      ...alertas.map(
                        (msg) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(msg)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Distribución de Gastos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: gastosPorCategoria.isEmpty
                          ? const Center(child: Text("Sin gastos registrados"))
                          : PieChart(
                              PieChartData(
                                sections: gastosPorCategoria.entries.map((entry) {
                                  final color = _colorParaCategoria(entry.key);
                                  final porcentajeLocal =
                                      ((entry.value / totalGastado) * 100).toStringAsFixed(1);
                                  return PieChartSectionData(
                                    value: entry.value,
                                    title: "$porcentajeLocal%",
                                    color: color,
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: gastosPorCategoria.entries.map((entry) {
                        final nombre = categorias[entry.key] ?? 'Otra';
                        final porcentaje = (entry.value / totalGastado) * 100;
                        final color = _colorParaCategoria(entry.key);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(width: 12, height: 12, color: color),
                              const SizedBox(width: 8),
                              Expanded(child: Text(nombre)),
                              Text("${porcentaje.toStringAsFixed(1)}%")
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: AppColors.primaryLight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _infoRow("💰 Ingresos del mes", formatPeso.format(totalIngresos > 0 ? totalIngresos : sueldo)),
                    const Divider(),
                    _infoRow("✅ Cobrado", formatPeso.format(cobrados), color: Colors.green),
                    const Divider(),
                    _infoRow("⏳ Pendiente", formatPeso.format((totalIngresos - cobrados).clamp(0, double.infinity)), color: Colors.orange),
                    const Divider(),
                    _infoRow("💸 Gastado", formatPeso.format(totalGastado)),
                    const Divider(),
                    _infoRow("📉 Disponible", formatPeso.format(disponible),
                        color: disponible >= 0 ? Colors.green : Colors.red),
                    const Divider(),
                    _infoRow("🔴 Resta pagar", formatPeso.format(restantePagar), color: Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (proximosGastos.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Gastos próximos a vencer",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ...proximosGastos.map((gasto) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(gasto.descripcion, style: const TextStyle(fontSize: 14))),
                              Text(
                                DateFormat('dd/MM/yyyy').format(gasto.fechaVencimiento),
                                style: const TextStyle(color: Colors.redAccent),
                              )
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (porcentaje >= 80)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "⚠️ Estás usando más del 80% de tu sueldo mensual",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          )
        ],
      ),
    );
  }

  Color _colorParaCategoria(String id) {
    final colores = [
      AppColors.primary,
      Colors.orange,
      Colors.blue,
      Colors.teal,
      Colors.purple,
      Colors.pink,
      Colors.brown,
    ];
    return colores[id.hashCode % colores.length];
  }
}
