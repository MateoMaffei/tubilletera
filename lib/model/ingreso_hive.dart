import 'package:hive/hive.dart';
part 'ingreso.g.dart';

@HiveType(typeId: 2)
class Ingreso extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombreDeudor;

  @HiveField(2)
  double monto;

  @HiveField(3)
  DateTime fechaVencimiento;

  @HiveField(4)
  bool estado;

  @HiveField(5)
  DateTime fechaCreacion;

  @HiveField(6)
  String? detalles;

  Ingreso({
    required this.id,
    required this.nombreDeudor,
    required this.monto,
    required this.fechaVencimiento,
    this.estado = false,
    required this.fechaCreacion,
    this.detalles,
  });
}
