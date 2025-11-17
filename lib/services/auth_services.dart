import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tubilletera/services/user_local_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserLocalService _local = UserLocalService();

  Future<UserCredential> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required DateTime? fechaNacimiento,
    double? sueldo,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('usuarios').doc(credential.user!.uid).set({
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'sueldo': sueldo,
      'biometria': false,
      'creado': FieldValue.serverTimestamp(),
    });

    await _guardarPerfilLocal(credential.user!.uid);
    return credential;
  }

  Future<UserCredential> loginUsuario({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _guardarPerfilLocal(credential.user!.uid);
    return credential;
  }

  Future<UserCredential> loginConGoogle() async {
    UserCredential userCredential;
    try {
      // Intenta el flujo nativo recomendado por Firebase Auth
      userCredential = await _auth.signInWithProvider(GoogleAuthProvider());
    } catch (_) {
      // Fallback al plugin de GoogleSignIn para dispositivos que aún no soportan el nuevo flujo
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Inicio con Google cancelado');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(credential);
    }

    final doc = _db.collection('usuarios').doc(userCredential.user!.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'email': userCredential.user!.email,
        'nombre': userCredential.user!.displayName ?? '',
        'apellido': '',
        'fechaNacimiento': null,
        'sueldo': null,
        'biometria': false,
        'creado': FieldValue.serverTimestamp(),
      });
    }

    await _guardarPerfilLocal(userCredential.user!.uid);
    return userCredential;
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _local.clearSession();
  }

  User? get usuarioActual => _auth.currentUser;

  Future<Map<String, dynamic>?> obtenerDatosUsuario({String? uid}) async {
    final targetUid = uid ?? usuarioActual?.uid;
    if (targetUid == null) return null;

    final doc = await _db.collection('usuarios').doc(targetUid).get();
    final data = doc.data();
    if (data != null) {
      await _local.saveProfile(targetUid, data);
    }
    return data;
  }

  Future<void> actualizarBiometria(bool valor) async {
    final uid = usuarioActual?.uid;
    if (uid == null) return;

    await _db.collection('usuarios').doc(uid).update({'biometria': valor});
    final data = await obtenerDatosUsuario(uid: uid) ?? {};
    data['biometria'] = valor;
    await _local.saveProfile(uid, data);
  }

  Future<void> actualizarPerfil({
    required String nombre,
    required String apellido,
    DateTime? fechaNacimiento,
    double? sueldo,
  }) async {
    final uid = usuarioActual?.uid;
    if (uid == null) return;

    final payload = <String, dynamic>{
      'nombre': nombre,
      'apellido': apellido,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'sueldo': sueldo,
    };
    await _db.collection('usuarios').doc(uid).update(payload);
    final data = await obtenerDatosUsuario(uid: uid) ?? {};
    data.addAll(payload);
    await _local.saveProfile(uid, data);
  }

  Future<void> _guardarPerfilLocal(String uid) async {
    final data = await obtenerDatosUsuario(uid: uid);
    if (data != null) {
      await _local.saveProfile(uid, data);
    }
  }
}
