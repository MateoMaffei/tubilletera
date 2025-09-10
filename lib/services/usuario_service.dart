import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/usuario.dart';

class UsuarioService {
  final _firestore = FirebaseFirestore.instance;

  Future<Usuario?> obtenerUsuarioActual() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('usuarios').doc(uid).get();
    return doc.exists ? Usuario.fromMap(doc.data()!) : null;
  }

  Future<void> guardarUsuario(Usuario usuario) async {
    await _firestore.collection('usuarios').doc(usuario.id).set(usuario.toMap());
  }
}
