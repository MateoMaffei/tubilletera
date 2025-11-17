import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:tubilletera/model/categoria_hive.dart';
import 'package:tubilletera/model/gasto_hive.dart';
import 'package:tubilletera/model/ingreso_hive.dart';

class MigracionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> migrarDatos({bool eliminarLocales = false}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    final categoriasBox = Hive.box<Categoria>('categoriasBox');
    final gastosBox = Hive.box<Gasto>('gastoBox');
    final ingresosBox = Hive.box<Ingreso>('ingresoBox');

    for (final categoria in categoriasBox.values) {
      await firestore
          .collection('usuarios')
          .doc(uid)
          .collection('categorias')
          .doc(categoria.id)
          .set({
        'id': categoria.id,
        'descripcion': categoria.descripcion,
        'icono': categoria.icono,
      }, SetOptions(merge: true));
    }

    for (final gasto in gastosBox.values) {
      await firestore
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
      }, SetOptions(merge: true));
    }

    for (final ingreso in ingresosBox.values) {
      await firestore
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
      }, SetOptions(merge: true));
    }

    if (eliminarLocales) {
      await categoriasBox.clear();
      await gastosBox.clear();
      await ingresosBox.clear();
    }
  }
}
