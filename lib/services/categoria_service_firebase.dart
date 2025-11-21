import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../model/categoria.dart';

class CategoriaServiceFirebase {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String get _uid => _auth.currentUser!.uid;

  Future<List<Categoria>> obtenerTodas() async {
    final snapshot = await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .get();

    return snapshot.docs.map((e) => Categoria.fromMap(e.data())).toList();
  }

  Future<void> crearCategoria(String descripcion, String icono) async {
    final categoria = Categoria.crearNueva(_uuid.v4(), descripcion, icono);
    await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .doc(categoria.id)
        .set(categoria.toMap());
  }

  Future<void> actualizarCategoria(
      String id, String descripcion, String icono) async {
    final categoria = Categoria(
      id: id,
      descripcion: descripcion,
      icono: icono,
    );
    await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .doc(id)
        .update(categoria.toMap());
  }

  Future<void> eliminarCategoria(String id) async {
    await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .doc(id)
        .delete();
  }
}
