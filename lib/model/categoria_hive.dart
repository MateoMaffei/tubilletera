import 'package:hive/hive.dart';
part 'categoria.g.dart';

@HiveType(typeId: 0)
class Categoria extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String descripcion;

  // @HiveField(2)
  // String idUsuario;

  @HiveField(2)
  String icono;

  Categoria({
    required this.id,
    required this.descripcion,
    // required this.idUsuario,
    required this.icono,
  });
}
