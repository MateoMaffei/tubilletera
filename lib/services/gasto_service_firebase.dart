import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/gasto.dart';

class GastoServiceFirebase {
  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Gasto>> obtenerTodos() async {
    final snapshot = await _firestore
        .collection('gastos')
        .doc(_uid)
        .collection('items')
        .get();

    return snapshot.docs.map((e) => Gasto.fromMap(e.data())).toList();
  }

  Future<void> crearGasto(Gasto gasto) async {
    await _firestore
        .collection('gastos')
        .doc(_uid)
        .collection('items')
        .doc(gasto.id)
        .set(gasto.toMap());
  }

  Future<void> actualizarGasto(Gasto gasto) async {
    await _firestore
        .collection('gastos')
        .doc(_uid)
        .collection('items')
        .doc(gasto.id)
        .update(gasto.toMap());
  }

  Future<void> eliminarGasto(String id) async {
    await _firestore
        .collection('gastos')
        .doc(_uid)
        .collection('items')
        .doc(id)
        .delete();
  }
}
