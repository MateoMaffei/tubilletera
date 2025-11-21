import 'package:hive/hive.dart';
part 'gasto_tercero.g.dart';

@HiveType(typeId: 2)
class GastoTercero extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String persona;

  @HiveField(2)
  double montoTotal;

  @HiveField(3)
  int cantidadCuotas;

  @HiveField(4)
  double montoPorCuota;

  @HiveField(5)
  List<CuotaTercero> cuotas;

  GastoTercero({
    required this.id,
    required this.persona,
    required this.montoTotal,
    required this.cantidadCuotas,
    required this.montoPorCuota,
    required this.cuotas,
  });
}

@HiveType(typeId: 3)
class CuotaTercero {
  @HiveField(0)
  int numero;

  @HiveField(1)
  DateTime fechaVencimiento;

  @HiveField(2)
  double monto;

  @HiveField(3)
  bool pagada;

  CuotaTercero({
    required this.numero,
    required this.fechaVencimiento,
    required this.monto,
    this.pagada = false,
  });
}
