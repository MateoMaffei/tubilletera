// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hive/hive.dart';
// import 'package:tubilletera/model/categoria_hive.dart';
// import 'package:tubilletera/model/gasto_hive.dart';

// class MigracionService {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;

//   Future<void> migrarDatos() async {
//     final uid = auth.currentUser?.uid;
//     if (uid == null) throw Exception("Usuario no autenticado");

//     final categoriasBox = Hive.box<Categoria>('categoriasBox');
//     final gastosBox = Hive.box<Gasto>('gastoBox');

//     // 🔁 Subir Categorías
//     for (final categoria in categoriasBox.values) {
//       await firestore
//           .collection('categorias')
//           .doc(uid)
//           .collection('items')
//           .doc(categoria.id)
//           .set({
//         'id': categoria.id,
//         'descripcion': categoria.descripcion,
//         'idUsuario': uid,
//         'icono': categoria.icono,
//       });
//     }

//     // 🔁 Subir Gastos
//     for (final gasto in gastosBox.values) {
//       await firestore
//           .collection('gastos')
//           .doc(uid)
//           .collection('items')
//           .doc(gasto.id)
//           .set({
//         'id': gasto.id,
//         'descripcion': gasto.descripcion,
//         'idCategoria': gasto.idCategoria,
//         'idUsuario': uid,
//         'monto': gasto.monto,
//         'fechaVencimiento': gasto.fechaVencimiento.toIso8601String(),
//         'detalles': gasto.detalles,
//         'estado': gasto.estado,
//         'fechaCreacion': gasto.fechaCreacion.toIso8601String(),
//       });
//     }

//     // ✅ Eliminar datos locales de Hive si todo sale bien
//     await categoriasBox.clear();
//     await gastosBox.clear();
//   }
// }
