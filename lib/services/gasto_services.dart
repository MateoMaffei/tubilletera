import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:tubilletera/model/gasto_hive.dart';
import 'package:uuid/uuid.dart';

class GastoService {
  final Box<Gasto> _box = Hive.box<Gasto>('gastoBox');
  final _uuid = const Uuid();

  List<Gasto> obtenerTodos() {
    return _box.values.toList();
  }
  
  /// Obtener todos los gastos que vencen en un mes específico
  List<Gasto> obtenerPorMes(int anio, int mes) {
    return _box.values.where((gasto) {
      return gasto.fechaVencimiento.year == anio &&
             gasto.fechaVencimiento.month == mes;
    }).toList();
  }

  List<Gasto>? obtenerPorCategoria(String idCategoria) {
    return _box.values.where((g) => g.idCategoria == idCategoria).toList();
  }

  Gasto? obtenerporId(String id) {
    return _box.values.firstWhereOrNull((g) => g.id == id);
  }

  
  Future<void> crearGasto({
    required String descripcion,
    required String idCategoria,
    required double monto,
    required DateTime fechaVencimiento,
    String? detalles,
    bool estado = false,
  }) async {
    final nuevo = Gasto(
      id: _uuid.v4(),
      descripcion: descripcion,
      idCategoria: idCategoria,
      monto: monto,
      fechaVencimiento: fechaVencimiento,
      detalles: detalles,
      estado: estado,
      fechaCreacion: DateTime.now(),
    );
    await _box.add(nuevo);
  }

  /// Actualizar un gasto existente
  Future<void> actualizarGasto(Gasto gasto, {
    required String descripcion,
    required String idCategoria,
    required double monto,
    required DateTime fechaVencimiento,
    String? detalles,
    required bool estado }) async 
  {
    gasto.descripcion = descripcion;
    gasto.idCategoria = idCategoria;
    gasto.monto = monto;
    gasto.fechaVencimiento = fechaVencimiento;
    gasto.detalles = detalles;
    gasto.estado = estado;
    await gasto.save();
  }

  Future<void> pagarGasto(Gasto gasto) async 
  {
    gasto.estado = true;
    await gasto.save();
  }

  /// Eliminar gasto por ID
  Future<void> eliminarGasto(String id) async {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == id,
      orElse: () => null,
    );
    if (key != null) {
      await _box.delete(key);
    }
  }

  /// Retorna todos los gastos del mes actual
  List<Gasto> obtenerGastosDelMesActual() {
    final now = DateTime.now();
    return _box.values.where((gasto) =>
      gasto.fechaVencimiento.month == now.month &&
      gasto.fechaVencimiento.year == now.year
    ).toList();
  }

  /// Suma total de gastos del mes (pagados y no pagados)
  double totalGastadoMesActual() {
    return obtenerGastosDelMesActual()
      .fold(0.0, (acc, gasto) => acc + gasto.monto);
  }

  /// Total que ya fue pagado (estado == true)
  double totalPagadoMesActual() {
    return obtenerGastosDelMesActual()
      .where((gasto) => gasto.estado)
      .fold(0.0, (acc, gasto) => acc + gasto.monto);
  }

  /// Total que aún no se ha pagado
  double totalRestanteMesActual() {
    final total = totalGastadoMesActual();
    final pagado = totalPagadoMesActual();
    return total - pagado;
  }

}
