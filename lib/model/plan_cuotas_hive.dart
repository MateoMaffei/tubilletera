import 'package:hive/hive.dart';

part 'plan_cuotas.g.dart';

@HiveType(typeId: 4)
class PlanCuotas extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String deudorId;

  @HiveField(2)
  String nombreGasto;

  @HiveField(3)
  double montoTotal;

  @HiveField(4)
  int cantidadTotalCuotas;

  @HiveField(5)
  DateTime fechaInicio;

  @HiveField(6)
  int cuotasPagadasIniciales;

  PlanCuotas({
    required this.id,
    required this.deudorId,
    required this.nombreGasto,
    required this.montoTotal,
    required this.cantidadTotalCuotas,
    required this.fechaInicio,
    this.cuotasPagadasIniciales = 0,
  });

  double get montoCuota => montoTotal / (cantidadTotalCuotas == 0 ? 1 : cantidadTotalCuotas);
}
