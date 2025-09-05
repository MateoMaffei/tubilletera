// import 'package:firebase_auth/firebase_auth.dart';

class Categoria {

  final String id;
  final String descripcion;
  final String icono;
  // final String idUsuario;

  Categoria({
    required this.id,
    required this.descripcion,
    required this.icono,
    // required this.idUsuario,
  });

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
    id: map['id'],
    descripcion: map['descripcion'],
    icono: map['icono'],
    // idUsuario: map['idUsuario'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'descripcion': descripcion,
    'icono': icono,
    // 'idUsuario': idUsuario,
  };

  factory Categoria.crearNueva(String uuid, String desc, String icono) => Categoria(
    id: uuid,
    descripcion: desc,
    icono: icono,
    // idUsuario: FirebaseAuth.instance.currentUser!.uid,
  );
}
