import 'package:hive/hive.dart';

part 'cuota_estado.g.dart';

@HiveType(typeId: 10)
enum CuotaEstado {
  @HiveField(0)
  pendiente,

  @HiveField(1)
  pagada,
}
