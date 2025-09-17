import 'dart:math';

import 'package:tubilletera/model/cuota_estado.dart';
import 'package:tubilletera/model/cuota_terceros.dart';
import 'package:tubilletera/model/gasto_terceros.dart';

class ThirdPartyExpenseCalculator {
  static List<CuotaTercero> generarCuotas({
    required double montoTotal,
    required int cantidadCuotas,
    required DateTime fechaPrimerVencimiento,
    double? montoPorCuota,
  }) {
    if (cantidadCuotas <= 0) {
      throw ArgumentError('La cantidad de cuotas debe ser mayor a cero');
    }

    final montos = _calcularMontosCuotas(
      montoTotal: montoTotal,
      cantidadCuotas: cantidadCuotas,
      montoPorCuota: montoPorCuota,
    );

    return List<CuotaTercero>.generate(cantidadCuotas, (index) {
      final fecha = _calcularFechaCuota(fechaPrimerVencimiento, index);
      return CuotaTercero(
        id: '${fecha.millisecondsSinceEpoch}-$index',
        monto: montos[index],
        fechaVencimiento: fecha,
        estado: CuotaEstado.pendiente,
      );
    });
  }

  static double totalAdeudadoPorPersona(
    List<GastoTercero> gastos,
  ) {
    return gastos.fold<double>(0, (suma, gasto) => suma + gasto.totalAdeudado);
  }

  static double totalPagadoPorPersona(List<GastoTercero> gastos) {
    return gastos.fold<double>(0, (suma, gasto) => suma + gasto.totalPagado);
  }

  static double totalPendientePorPersona(List<GastoTercero> gastos) {
    return gastos.fold<double>(0, (suma, gasto) => suma + gasto.totalPendiente);
  }

  static List<double> _calcularMontosCuotas({
    required double montoTotal,
    required int cantidadCuotas,
    double? montoPorCuota,
  }) {
    final totalRedondeado = _redondear(montoTotal);
    if (montoPorCuota != null) {
      final totalCalculado = _redondear(montoPorCuota * cantidadCuotas);
      if ((totalCalculado - totalRedondeado).abs() > 0.01) {
        throw ArgumentError(
          'El total informado no coincide con el calculado a partir del monto por cuota.',
        );
      }
    }

    final cuotaBase = montoPorCuota ?? (totalRedondeado / cantidadCuotas);
    final cuotaRedondeada = _redondear(cuotaBase);

    final montos = List<double>.filled(cantidadCuotas, cuotaRedondeada);
    final sumaPrevia = _redondear(cuotaRedondeada * (cantidadCuotas - 1));
    montos[cantidadCuotas - 1] = _redondear(totalRedondeado - sumaPrevia);
    return montos;
  }

  static DateTime _calcularFechaCuota(DateTime fechaInicial, int index) {
    final fechaBase = DateTime(fechaInicial.year, fechaInicial.month + index, 1);
    final ultimoDiaMes = DateTime(fechaBase.year, fechaBase.month + 1, 0).day;
    final dia = min(fechaInicial.day, ultimoDiaMes);
    return DateTime(fechaBase.year, fechaBase.month, dia);
  }

  static double _redondear(double valor) => double.parse(valor.toStringAsFixed(2));
}
