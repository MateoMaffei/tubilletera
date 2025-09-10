import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../model/categoria.dart';

class CategoriaServiceFirebase {
  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _uuid = const Uuid();

  Future<List<Categoria>> obtenerTodas() async {
    final snapshot = await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .get();

    return snapshot.docs.map((e) => Categoria.fromMap(e.data())).toList();
  }

  Future<void> crearCategoria(String descripcion, String icono) async {
    final categoria = Categoria(
      id: _uuid.v4(),
      descripcion: descripcion,
      icono: icono,
    );
    await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .doc(categoria.id)
        .set(categoria.toMap());
  }

  Future<void> actualizarCategoria(
      String id, String descripcion, String icono) async {
    await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .doc(id)
        .update({'descripcion': descripcion, 'icono': icono});
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
