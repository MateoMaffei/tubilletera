import 'package:hive/hive.dart';

part 'persona_terceros.g.dart';

@HiveType(typeId: 12)
class PersonaTercero extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String apellido;

  @HiveField(3)
  String? email;

  PersonaTercero({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.email,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();
}
