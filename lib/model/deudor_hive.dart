import 'package:hive/hive.dart';

part 'deudor.g.dart';

@HiveType(typeId: 3)
class Deudor extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String? telefono;

  @HiveField(3)
  String? nota;

  Deudor({
    required this.id,
    required this.nombre,
    this.telefono,
    this.nota,
  });
}
