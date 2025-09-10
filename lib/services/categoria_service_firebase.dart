import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/categoria.dart';

class CategoriaServiceFirebase {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<List<Categoria>> obtenerTodas() async {
    final snapshot = await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .get();

    return snapshot.docs.map((e) => Categoria.fromMap(e.data())).toList();
  }

  Future<void> crear(Categoria categoria) async {
    await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .doc(categoria.id)
        .set(categoria.toMap());
  }

  Future<void> actualizar(Categoria categoria) async {
    await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .doc(categoria.id)
        .update(categoria.toMap());
  }

  Future<void> eliminar(String id) async {
    await _firestore
        .collection('categorias')
        .doc(_uid)
        .collection('items')
        .doc(id)
        .delete();
  }
}
