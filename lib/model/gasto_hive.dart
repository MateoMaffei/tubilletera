import 'package:hive/hive.dart';
part 'gasto.g.dart';

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String descripcion;
  
  @HiveField(2)
  String idCategoria;

  @HiveField(3)
  double monto;

  @HiveField(4)
  DateTime fechaVencimiento;

  @HiveField(5)
  String? detalles;

  @HiveField(6)
  bool estado;

  @HiveField(7)
  DateTime fechaCreacion;

  Gasto({
    required this.id,
    required this.descripcion,
    required this.idCategoria,
    required this.monto,
    required this.fechaVencimiento,
    this.detalles,
    required this.estado,
    required this.fechaCreacion
  });
}
