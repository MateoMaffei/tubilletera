import 'package:hive/hive.dart';

part 'cuota.g.dart';

@HiveType(typeId: 5)
class Cuota extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String planCuotasId;

  @HiveField(2)
  int numeroCuota;

  @HiveField(3)
  double montoCuota;

  @HiveField(4)
  DateTime fechaVencimiento;

  @HiveField(5)
  bool pagada;

  @HiveField(6)
  DateTime? fechaPago;

  Cuota({
    required this.id,
    required this.planCuotasId,
    required this.numeroCuota,
    required this.montoCuota,
    required this.fechaVencimiento,
    this.pagada = false,
    this.fechaPago,
  });
}
