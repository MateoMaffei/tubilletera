// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   Future<User?> registrarUsuario({
//     required String email,
//     required String password,
//     required String nombre,
//     required String apellido,
//     required DateTime fechaNacimiento,
//     double? sueldo,
//   }) async {
//     try {
//       final credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       await _db.collection('usuarios').doc(credential.user!.uid).set({
//         'email': email,
//         'nombre': nombre,
//         'apellido': apellido,
//         'fechaNacimiento': fechaNacimiento.toIso8601String(),
//         'sueldo': sueldo,
//         'biometria': false,
//         'creado': FieldValue.serverTimestamp(),
//       });

//       return credential.user;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<User?> loginUsuario({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return credential.user;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> logout() async {
//     await _auth.signOut();
//   }

//   User? get usuarioActual => _auth.currentUser;

//   Future<Map<String, dynamic>?> obtenerDatosUsuario() async {
//     final uid = usuarioActual?.uid;
//     if (uid == null) return null;

//     final doc = await _db.collection('usuarios').doc(uid).get();
//     return doc.data();
//   }

//   Future<void> actualizarBiometria(bool valor) async {
//     final uid = usuarioActual?.uid;
//     if (uid == null) return;

//     await _db.collection('usuarios').doc(uid).update({
//       'biometria': valor,
//     });
//   }
// }
