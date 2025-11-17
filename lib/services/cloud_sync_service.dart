import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tubilletera/model/categoria_hive.dart';
import 'package:tubilletera/model/gasto_hive.dart';
import 'package:tubilletera/model/ingreso_hive.dart';

class CloudSyncService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> upsertCategoria(Categoria categoria) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('categorias')
        .doc(categoria.id)
        .set({
      'id': categoria.id,
      'descripcion': categoria.descripcion,
      'icono': categoria.icono,
    });
  }

  Future<void> deleteCategoria(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('categorias')
        .doc(id)
        .delete();
  }

  Future<void> upsertGasto(Gasto gasto) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('gastos')
        .doc(gasto.id)
        .set({
      'id': gasto.id,
      'descripcion': gasto.descripcion,
      'idCategoria': gasto.idCategoria,
      'monto': gasto.monto,
      'fechaVencimiento': gasto.fechaVencimiento.toIso8601String(),
      'detalles': gasto.detalles,
      'estado': gasto.estado,
      'fechaCreacion': gasto.fechaCreacion.toIso8601String(),
    });
  }

  Future<void> deleteGasto(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('gastos')
        .doc(id)
        .delete();
  }

  Future<void> upsertIngreso(Ingreso ingreso) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('ingresos')
        .doc(ingreso.id)
        .set({
      'id': ingreso.id,
      'nombreDeudor': ingreso.nombreDeudor,
      'monto': ingreso.monto,
      'fechaVencimiento': ingreso.fechaVencimiento.toIso8601String(),
      'estado': ingreso.estado,
      'fechaCreacion': ingreso.fechaCreacion.toIso8601String(),
    });
  }

  Future<void> deleteIngreso(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('ingresos')
        .doc(id)
        .delete();
  }
}
