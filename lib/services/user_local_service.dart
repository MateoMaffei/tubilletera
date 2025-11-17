import 'package:hive_flutter/hive_flutter.dart';

class UserLocalService {
  Box<dynamic> get _box => Hive.box('usersBox');

  String? get loggedUserId => _box.get('loggedUser') as String?;

  Map<String, dynamic>? getLoggedProfile() {
    final uid = loggedUserId;
    if (uid == null) return null;
    final data = _box.get(uid);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();
    return null;
  }

  /// Busca en Hive un usuario legado que haya guardado email y password en local.
  ///
  /// Devuelve el primer mapa que contenga ambas claves, o `null` si no existe.
  Map<String, dynamic>? findLegacyCredentials() {
    for (final entry in _box.values) {
      if (entry is Map) {
        final map = Map<String, dynamic>.from(entry);
        if (map['email'] is String && map['password'] is String) {
          return map;
        }
      }
    }
    return null;
  }

  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {
    await _box.put(uid, Map<String, dynamic>.from(data));
    await _box.put('loggedUser', uid);
  }

  Future<void> clearSession() async {
    final uid = loggedUserId;
    await _box.delete('loggedUser');
    if (uid != null) {
      await _box.delete(uid);
    }
  }
}
