import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:tubilletera/model/gasto_tercero_hive.dart';

class GastoTerceroService {
  final Box<GastoTercero> _box = Hive.box<GastoTercero>('gastosTercerosBox');
  final _uuid = const Uuid();

  List<GastoTercero> obtenerTodos() => _box.values.toList();

  Future<void> crear({
    required String persona,
    required double montoTotal,
    required int cantidadCuotas,
    required DateTime primeraCuota,
  }) async {
    final montoCuota = montoTotal / cantidadCuotas;
    final cuotas = List.generate(cantidadCuotas, (i) {
      final fecha = DateTime(primeraCuota.year, primeraCuota.month + i, primeraCuota.day);
      return CuotaTercero(
        numero: i + 1,
        fechaVencimiento: fecha,
        monto: montoCuota,
      );
    });
    final nuevo = GastoTercero(
      id: _uuid.v4(),
      persona: persona,
      montoTotal: montoTotal,
      cantidadCuotas: cantidadCuotas,
      montoPorCuota: montoCuota,
      cuotas: cuotas,
    );
    await _box.add(nuevo);
  }

  Future<void> actualizar(GastoTercero gasto, {
    required String persona,
    required double montoTotal,
    required int cantidadCuotas,
    required DateTime primeraCuota,
  }) async {
    gasto.persona = persona;
    gasto.montoTotal = montoTotal;
    gasto.cantidadCuotas = cantidadCuotas;
    gasto.montoPorCuota = montoTotal / cantidadCuotas;
    gasto.cuotas = List.generate(cantidadCuotas, (i) {
      final fecha = DateTime(primeraCuota.year, primeraCuota.month + i, primeraCuota.day);
      return CuotaTercero(
        numero: i + 1,
        fechaVencimiento: fecha,
        monto: gasto.montoPorCuota,
      );
    });
    await gasto.save();
  }

  Future<void> eliminar(GastoTercero gasto) async {
    await gasto.delete();
  }

  double totalPendienteDelMes(int anio, int mes) {
    double total = 0;
    for (final g in _box.values) {
      for (final c in g.cuotas) {
        if (!c.pagada && c.fechaVencimiento.year == anio && c.fechaVencimiento.month == mes) {
          total += c.monto;
        }
      }
    }
    return total;
  }

  double totalPagadoDelMes(int anio, int mes) {
    double total = 0;
    for (final g in _box.values) {
      for (final c in g.cuotas) {
        if (c.pagada && c.fechaVencimiento.year == anio && c.fechaVencimiento.month == mes) {
          total += c.monto;
        }
      }
    }
    return total;
  }

  List<CuotaTercero> cuotasDelMes(int anio, int mes) {
    return _box.values
      .expand((g) => g.cuotas.where((c) => c.fechaVencimiento.year == anio && c.fechaVencimiento.month == mes))
      .toList();
  }
}
