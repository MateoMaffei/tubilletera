import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:tubilletera/model/cuota_hive.dart';
import 'package:tubilletera/model/plan_cuotas_hive.dart';
import 'package:uuid/uuid.dart';

class PlanCuotasDetalle {
  final PlanCuotas plan;
  final List<Cuota> cuotas;

  PlanCuotasDetalle({required this.plan, required this.cuotas});

  double get montoCuota => plan.montoCuota;

  int get cuotasPagadas => cuotas.where((c) => c.pagada).length;

  int get cuotasAdeudadas {
    final hoy = DateTime.now();
    return cuotas
        .where((c) => !c.pagada && !c.fechaVencimiento.isAfter(DateTime(hoy.year, hoy.month, hoy.day)))
        .length;
  }

  int get cuotasRestantes => cuotas.length - cuotasPagadas;

  double get montoTotalAdeudado =>
      cuotas.where((c) => !c.pagada).fold<double>(0, (sum, c) => sum + c.montoCuota);
}

class PlanCuotasService {
  final Box<PlanCuotas> _planesBox = Hive.box<PlanCuotas>('planesCuotasBox');
  final Box<Cuota> _cuotasBox = Hive.box<Cuota>('cuotasBox');
  final _uuid = const Uuid();

  List<PlanCuotasDetalle> obtenerPlanesConCuotas() {
    final planes = _planesBox.values.toList();
    final cuotasPorPlan = <String, List<Cuota>>{};

    for (final cuota in _cuotasBox.values) {
      cuotasPorPlan.putIfAbsent(cuota.planCuotasId, () => []).add(cuota);
    }

    return planes
        .map(
          (plan) => PlanCuotasDetalle(
            plan: plan,
            cuotas: (cuotasPorPlan[plan.id] ?? [])..sort((a, b) => a.numeroCuota.compareTo(b.numeroCuota)),
          ),
        )
        .toList();
  }

  PlanCuotasDetalle? obtenerDetallePorPlan(String planId) {
    final plan = _planesBox.values.firstWhereOrNull((p) => p.id == planId);
    if (plan == null) return null;
    final cuotas = _cuotasBox.values.where((c) => c.planCuotasId == planId).toList()
      ..sort((a, b) => a.numeroCuota.compareTo(b.numeroCuota));
    return PlanCuotasDetalle(plan: plan, cuotas: cuotas);
  }

  Future<void> crearPlan({
    required String deudorId,
    required String nombreGasto,
    required double montoTotal,
    required int cantidadTotalCuotas,
    required DateTime fechaInicio,
    int cuotasPagadasIniciales = 0,
  }) async {
    final plan = PlanCuotas(
      id: _uuid.v4(),
      deudorId: deudorId,
      nombreGasto: nombreGasto,
      montoTotal: montoTotal,
      cantidadTotalCuotas: cantidadTotalCuotas,
      fechaInicio: fechaInicio,
      cuotasPagadasIniciales: cuotasPagadasIniciales,
    );
    await _planesBox.add(plan);
    await _generarCuotas(plan);
  }

  Future<void> actualizarPlan(
    PlanCuotas plan, {
    required String deudorId,
    required String nombreGasto,
    required double montoTotal,
    required int cantidadTotalCuotas,
    required DateTime fechaInicio,
    int cuotasPagadasIniciales = 0,
  }) async {
    plan
      ..deudorId = deudorId
      ..nombreGasto = nombreGasto
      ..montoTotal = montoTotal
      ..cantidadTotalCuotas = cantidadTotalCuotas
      ..fechaInicio = fechaInicio
      ..cuotasPagadasIniciales = cuotasPagadasIniciales;
    await plan.save();

    await _eliminarCuotasPlan(plan.id);
    await _generarCuotas(plan);
  }

  Future<void> _generarCuotas(PlanCuotas plan) async {
    final montoCuota = plan.montoCuota;
    for (int i = 0; i < plan.cantidadTotalCuotas; i++) {
      final numero = i + 1;
      final fecha = DateTime(plan.fechaInicio.year, plan.fechaInicio.month + i, plan.fechaInicio.day);
      final pagada = numero <= plan.cuotasPagadasIniciales;
      final cuota = Cuota(
        id: _uuid.v4(),
        planCuotasId: plan.id,
        numeroCuota: numero,
        montoCuota: montoCuota,
        fechaVencimiento: fecha,
        pagada: pagada,
        fechaPago: pagada ? fecha : null,
      );
      await _cuotasBox.add(cuota);
    }
  }

  Future<void> _eliminarCuotasPlan(String planId) async {
    final keys = _cuotasBox.keys.where((k) => _cuotasBox.get(k)?.planCuotasId == planId).toList();
    await _cuotasBox.deleteAll(keys);
  }

  Future<void> marcarCuotaComoPagada(Cuota cuota, bool pagada) async {
    cuota
      ..pagada = pagada
      ..fechaPago = pagada ? DateTime.now() : null;
    await cuota.save();
  }

  Future<void> eliminarPlan(String planId) async {
    final planKey = _planesBox.keys.firstWhereOrNull((k) => _planesBox.get(k)?.id == planId);
    if (planKey != null) {
      await _planesBox.delete(planKey);
    }
    await _eliminarCuotasPlan(planId);
  }

  List<Cuota> obtenerCuotasPorMes(int anio, int mes) {
    return _cuotasBox.values
        .where((c) => c.fechaVencimiento.year == anio && c.fechaVencimiento.month == mes)
        .toList();
  }

  double totalCuotasMes(int anio, int mes) {
    return obtenerCuotasPorMes(anio, mes).fold(0, (sum, c) => sum + c.montoCuota);
  }

  double totalCuotasCobradasMes(int anio, int mes) {
    return obtenerCuotasPorMes(anio, mes)
        .where((c) => c.pagada)
        .fold(0, (sum, c) => sum + c.montoCuota);
  }
}
