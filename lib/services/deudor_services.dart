import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:tubilletera/model/deudor_hive.dart';
import 'package:uuid/uuid.dart';

class DeudorService {
  final Box<Deudor> _box = Hive.box<Deudor>('deudoresBox');
  final _uuid = const Uuid();

  List<Deudor> obtenerTodos() {
    return _box.values.toList();
  }

  Deudor? obtenerPorId(String id) {
    return _box.values.firstWhereOrNull((d) => d.id == id);
  }

  Future<void> crearDeudor({
    required String nombre,
    String? telefono,
    String? nota,
  }) async {
    final deudor = Deudor(
      id: _uuid.v4(),
      nombre: nombre,
      telefono: telefono,
      nota: nota,
    );
    await _box.add(deudor);
  }

  Future<void> actualizarDeudor(
    Deudor deudor, {
    required String nombre,
    String? telefono,
    String? nota,
  }) async {
    deudor
      ..nombre = nombre
      ..telefono = telefono
      ..nota = nota;
    await deudor.save();
  }

  Future<void> eliminarDeudor(String id) async {
    final key = _box.keys.firstWhereOrNull((k) => _box.get(k)?.id == id);
    if (key != null) {
      await _box.delete(key);
    }
  }
}
