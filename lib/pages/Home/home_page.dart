// Asegurate de tener estas importaciones
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:tubilletera/model/gasto_hive.dart';
import 'package:tubilletera/model/categoria_hive.dart';
import 'package:tubilletera/model/ingreso_hive.dart';
import 'package:tubilletera/components/app_shell.dart';
import 'package:tubilletera/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedMonth = DateTime.now();
  bool mostrarRecordatorios = true;
  bool mostrarInsights = true;
  bool autopagar = false;

  @override
  Widget build(BuildContext context) {
    final gastosBox = Hive.box<Gasto>('gastoBox');
    final categoriasBox = Hive.box<Categoria>('categoriasBox');
    final ingresosBox = Hive.box<Ingreso>('ingresoBox');
    final usersBox = Hive.box('usersBox');
    final email = usersBox.get('loggedUser');
    final user = usersBox.get(email);
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
    final totalTercerosPendiente = 0.0;
    final mesSeleccionado = DateFormat.yMMMM('es_AR').format(selectedMonth);

    return AppShell(
      section: AppSection.home,
      title: 'Panel principal',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del mes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      mesSeleccionado,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                TextButton.icon(
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
                  label: const Text('Cambiar mes'),
                )
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statCard(
                  title: 'Disponible',
                  value: formatPeso.format(disponible),
                  icon: Icons.wallet_rounded,
                  accent: AppColors.primaryAlt,
                  progress: (disponible / (baseIngresos == 0 ? 1 : baseIngresos)).clamp(0, 1),
                ),
                _statCard(
                  title: 'Gastado',
                  value: formatPeso.format(totalGastado),
                  icon: Icons.flash_on,
                  accent: AppColors.accent,
                  progress: (totalGastado / (baseIngresos == 0 ? 1 : baseIngresos)).clamp(0, 1),
                ),
                _statCard(
                  title: 'Resta pagar',
                  value: formatPeso.format(restantePagar),
                  icon: Icons.warning_amber_rounded,
                  accent: Colors.orangeAccent,
                  progress: (restantePagar / (baseIngresos == 0 ? 1 : baseIngresos)).clamp(0, 1),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceAlt, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Panel de control', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('Personalizable', style: TextStyle(color: AppColors.textSecondary)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _controlToggle(
                        title: 'Recordatorios',
                        subtitle: 'Notificaciones diarias de vencimientos',
                        value: mostrarRecordatorios,
                        onChanged: (v) => setState(() => mostrarRecordatorios = v),
                      ),
                      _controlToggle(
                        title: 'Insights',
                        subtitle: 'Recomendaciones inteligentes',
                        value: mostrarInsights,
                        onChanged: (v) => setState(() => mostrarInsights = v),
                      ),
                      _controlToggle(
                        title: 'Autopagar',
                        subtitle: 'Confirma pagos marcados',
                        value: autopagar,
                        onChanged: (v) => setState(() => autopagar = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Distribución de gastos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 230,
                    child: gastosPorCategoria.isEmpty
                        ? const Center(child: Text('Sin gastos registrados'))
                        : PieChart(
                            PieChartData(
                              sections: gastosPorCategoria.entries.map((entry) {
                                final color = _colorParaCategoria(entry.key);
                                final porcentajeLocal = ((entry.value / totalGastado) * 100).toStringAsFixed(1);
                                return PieChartSectionData(
                                  value: entry.value,
                                  title: "$porcentajeLocal%",
                                  color: color,
                                  radius: 58,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 38,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  Column(
                    children: gastosPorCategoria.entries.map((entry) {
                      final nombre = categorias[entry.key] ?? 'Otra';
                      final porcentaje = (entry.value / totalGastado) * 100;
                      final color = _colorParaCategoria(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
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
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Balance vivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 12),
                  _infoRow("💰 Ingresos del mes", formatPeso.format(totalIngresos > 0 ? totalIngresos : sueldo), color: Colors.white),
                  const Divider(color: Colors.white24),
                  _infoRow("✅ Cobrado", formatPeso.format(cobrados), color: Colors.white),
                  const Divider(color: Colors.white24),
                  _infoRow("⏳ Pendiente", formatPeso.format((totalIngresos - cobrados).clamp(0, double.infinity)), color: Colors.white70),
                  const Divider(color: Colors.white24),
                  _infoRow("💸 Gastado", formatPeso.format(totalGastado), color: Colors.white),
                  const Divider(color: Colors.white24),
                  _infoRow("📉 Disponible", formatPeso.format(disponible), color: Colors.white),
                  const Divider(color: Colors.white24),
                  _infoRow("🔴 Resta pagar", formatPeso.format(restantePagar), color: Colors.white),
                  const Divider(color: Colors.white24),
                  _infoRow("🤝 Adeudado por terceros", formatPeso.format(totalTercerosPendiente), color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (proximosGastos.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gastos próximos a vencer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ...proximosGastos.map((gasto) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(gasto.descripcion, style: const TextStyle(fontSize: 14))),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 16, color: Colors.orangeAccent),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('dd/MM').format(gasto.fechaVencimiento),
                                  style: const TextStyle(color: Colors.orangeAccent),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    })
                  ],
                ),
              ),
            const SizedBox(height: 18),
            if (porcentaje >= 80)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
                ),
                child: const Text(
                  "⚠️ Estás usando más del 80% de tu sueldo mensual",
                  style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accent,
    required double progress,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.15),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          )
        ],
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
