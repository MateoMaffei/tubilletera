import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:tubilletera/model/ingreso_hive.dart';
import 'package:uuid/uuid.dart';
import 'cloud_sync_service.dart';

class IngresoService {
  final Box<Ingreso> _box = Hive.box<Ingreso>('ingresoBox');
  final _uuid = const Uuid();
  final _cloud = CloudSyncService();

  List<Ingreso> obtenerTodos() {
    return _box.values.toList();
  }

  List<Ingreso> obtenerPorMes(int anio, int mes) {
    return _box.values
        .where((ing) => ing.fechaVencimiento.year == anio && ing.fechaVencimiento.month == mes)
        .toList();
  }

  Ingreso? obtenerPorId(String id) {
    return _box.values.firstWhereOrNull((ing) => ing.id == id);
  }

  Future<void> crearIngreso({
    required String nombreDeudor,
    required double monto,
    required DateTime fechaVencimiento,
    bool estado = false,
  }) async {
    final nuevo = Ingreso(
      id: _uuid.v4(),
      nombreDeudor: nombreDeudor,
      monto: monto,
      fechaVencimiento: fechaVencimiento,
      estado: estado,
      fechaCreacion: DateTime.now(),
    );
    await _box.add(nuevo);
    await _cloud.upsertIngreso(nuevo);
  }

  Future<void> actualizarIngreso(Ingreso ingreso, {
    required String nombreDeudor,
    required double monto,
    required DateTime fechaVencimiento,
    required bool estado,
  }) async {
    ingreso.nombreDeudor = nombreDeudor;
    ingreso.monto = monto;
    ingreso.fechaVencimiento = fechaVencimiento;
    ingreso.estado = estado;
    await ingreso.save();
    await _cloud.upsertIngreso(ingreso);
  }

  Future<void> marcarCobrado(Ingreso ingreso, bool estado) async {
    ingreso.estado = estado;
    await ingreso.save();
    await _cloud.upsertIngreso(ingreso);
  }

  Future<void> eliminarIngreso(String id) async {
    final key = _box.keys.firstWhereOrNull((k) => _box.get(k)?.id == id);
    if (key != null) {
      await _box.delete(key);
      await _cloud.deleteIngreso(id);
    }
  }

  double totalIngresosMes(int anio, int mes) {
    return obtenerPorMes(anio, mes).fold(0.0, (acc, ing) => acc + ing.monto);
  }

  Future<void> asegurarIngresosSueldo(double sueldo) async {
    final ahora = DateTime.now();

    for (int i = 0; i < 2; i++) {
      final fechaObjetivo = DateTime(ahora.year, ahora.month + i, 1);
      final existe = _box.values.any((ing) =>
          ing.nombreDeudor.toLowerCase() == 'sueldo mensual' &&
          ing.fechaVencimiento.year == fechaObjetivo.year &&
          ing.fechaVencimiento.month == fechaObjetivo.month);

      if (!existe) {
        await crearIngreso(
          nombreDeudor: 'Sueldo mensual',
          monto: sueldo,
          fechaVencimiento: fechaObjetivo,
        );
      }
    }
  }
}
