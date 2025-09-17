import 'package:test/test.dart';
import 'package:tubilletera/model/cuota_estado.dart';
import 'package:tubilletera/model/cuota_terceros.dart';
import 'package:tubilletera/model/gasto_terceros.dart';
import 'package:tubilletera/model/persona_terceros.dart';
import 'package:tubilletera/services/third_party_pdf_service.dart';

void main() {
  test('genera un PDF no vacío con el resumen de personas', () async {
    final servicio = ThirdPartyPdfService();
    final persona = PersonaTercero(id: '1', nombre: 'Ana', apellido: 'Pérez', email: 'ana@test.com');
    final gasto = GastoTercero(
      id: 'g1',
      personaId: '1',
      montoTotal: 500,
      cantidadCuotas: 2,
      fechaPrimerVencimiento: DateTime(2024, 1, 10),
      cuotas: [
        CuotaTercero(
          id: 'c1',
          monto: 250,
          fechaVencimiento: DateTime(2024, 1, 10),
          estado: CuotaEstado.pagada,
        ),
        CuotaTercero(
          id: 'c2',
          monto: 250,
          fechaVencimiento: DateTime(2024, 2, 10),
          estado: CuotaEstado.pendiente,
        ),
      ],
    );

    final bytes = await servicio.buildResumenPdf(
      personas: [persona],
      gastosPorPersona: {
        '1': [gasto],
      },
    );

    expect(bytes, isNotEmpty);
  });
}
