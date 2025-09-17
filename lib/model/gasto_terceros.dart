import 'package:hive/hive.dart';
import 'package:tubilletera/model/cuota_estado.dart';
import 'package:tubilletera/model/cuota_terceros.dart';

part 'gasto_terceros.g.dart';

@HiveType(typeId: 13)
class GastoTercero extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String personaId;

  @HiveField(2)
  double montoTotal;

  @HiveField(3)
  int cantidadCuotas;

  @HiveField(4)
  DateTime fechaPrimerVencimiento;

  @HiveField(5)
  List<CuotaTercero> cuotas;

  GastoTercero({
    required this.id,
    required this.personaId,
    required this.montoTotal,
    required this.cantidadCuotas,
    required this.fechaPrimerVencimiento,
    required this.cuotas,
  });

  double get totalPagado =>
      cuotas.where((c) => c.estado == CuotaEstado.pagada).fold(0, (sum, cuota) => sum + cuota.monto);

  double get totalPendiente =>
      cuotas.where((c) => c.estado != CuotaEstado.pagada).fold(0, (sum, cuota) => sum + cuota.monto);

  double get totalAdeudado =>
      cuotas.fold(0, (sum, cuota) => sum + cuota.monto);
}
