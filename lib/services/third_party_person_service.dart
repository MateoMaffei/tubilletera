import 'package:hive/hive.dart';
import 'package:tubilletera/model/persona_terceros.dart';

class ThirdPartyPersonService {
  static const String boxName = 'personasTercerosBox';

  Box<PersonaTercero> get _box => Hive.box<PersonaTercero>(boxName);

  List<PersonaTercero> obtenerPersonas() {
    final personas = _box.values.toList();
    personas.sort((a, b) => a.nombreCompleto.compareTo(b.nombreCompleto));
    return personas;
  }

  Future<void> guardarPersona(PersonaTercero persona) async {
    await _box.put(persona.id, persona);
  }

  Future<void> eliminarPersona(String personaId) async {
    await _box.delete(personaId);
  }
}
