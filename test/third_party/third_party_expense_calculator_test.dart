import 'package:test/test.dart';
import 'package:tubilletera/model/cuota_estado.dart';
import 'package:tubilletera/model/cuota_terceros.dart';
import 'package:tubilletera/model/gasto_terceros.dart';
import 'package:tubilletera/services/third_party_expense_calculator.dart';

void main() {
  group('ThirdPartyExpenseCalculator', () {
    test('genera cuotas con vencimientos mensuales consistentes', () {
      final fechaInicial = DateTime(2024, 1, 31);
      final cuotas = ThirdPartyExpenseCalculator.generarCuotas(
        montoTotal: 3000,
        cantidadCuotas: 3,
        fechaPrimerVencimiento: fechaInicial,
      );

      expect(cuotas, hasLength(3));
      expect(cuotas.first.fechaVencimiento.day, equals(31));
      expect(cuotas[1].fechaVencimiento.day, equals(29)); // febrero bisiesto
      expect(cuotas[2].fechaVencimiento.day, equals(31));
      final total = cuotas.fold<double>(0, (sum, cuota) => sum + cuota.monto);
      expect(total.toStringAsFixed(2), equals('3000.00'));
    });

    test('calcula correctamente los totales por persona', () {
      final gasto = GastoTercero(
        id: '1',
        personaId: 'persona',
        montoTotal: 600,
        cantidadCuotas: 3,
        fechaPrimerVencimiento: DateTime(2024, 1, 10),
        cuotas: [
          CuotaTercero(
            id: 'c1',
            monto: 200,
            fechaVencimiento: DateTime(2024, 1, 10),
            estado: CuotaEstado.pagada,
          ),
          CuotaTercero(
            id: 'c2',
            monto: 200,
            fechaVencimiento: DateTime(2024, 2, 10),
            estado: CuotaEstado.pendiente,
          ),
          CuotaTercero(
            id: 'c3',
            monto: 200,
            fechaVencimiento: DateTime(2024, 3, 10),
            estado: CuotaEstado.pendiente,
          ),
        ],
      );

      final gastos = [gasto];

      final totalAdeudado = ThirdPartyExpenseCalculator.totalAdeudadoPorPersona(gastos);
      final totalPagado = ThirdPartyExpenseCalculator.totalPagadoPorPersona(gastos);
      final totalPendiente = ThirdPartyExpenseCalculator.totalPendientePorPersona(gastos);

      expect(totalAdeudado, equals(600));
      expect(totalPagado, equals(200));
      expect(totalPendiente, equals(400));
    });
  });
}
