import 'package:hive/hive.dart';
import 'package:tubilletera/model/gasto_terceros.dart';
import 'package:tubilletera/model/persona_terceros.dart';

class ThirdPartyExpenseService {
  static const String boxName = 'gastosTercerosBox';

  Box<GastoTercero> get _box => Hive.box<GastoTercero>(boxName);

  List<GastoTercero> obtenerGastos() {
    final gastos = _box.values.toList();
    gastos.sort((a, b) => a.fechaPrimerVencimiento.compareTo(b.fechaPrimerVencimiento));
    return gastos;
  }

  List<GastoTercero> obtenerPorPersona(String personaId) {
    return obtenerGastos().where((gasto) => gasto.personaId == personaId).toList();
  }

  Future<void> guardarGasto(GastoTercero gasto) async {
    await _box.put(gasto.id, gasto);
  }

  Future<void> eliminarGasto(String gastoId) async {
    await _box.delete(gastoId);
  }

  Future<void> eliminarGastosDePersona(PersonaTercero persona) async {
    final gastos = obtenerPorPersona(persona.id);
    for (final gasto in gastos) {
      await _box.delete(gasto.id);
    }
  }
}
