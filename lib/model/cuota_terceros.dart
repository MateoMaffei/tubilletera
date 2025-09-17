import 'package:hive/hive.dart';
import 'package:tubilletera/model/cuota_estado.dart';

part 'cuota_terceros.g.dart';

@HiveType(typeId: 11)
class CuotaTercero extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double monto;

  @HiveField(2)
  DateTime fechaVencimiento;

  @HiveField(3)
  CuotaEstado estado;

  CuotaTercero({
    required this.id,
    required this.monto,
    required this.fechaVencimiento,
    this.estado = CuotaEstado.pendiente,
  });

  bool get estaVencida =>
      estado == CuotaEstado.pendiente &&
      fechaVencimiento.isBefore(DateTime.now());
}
