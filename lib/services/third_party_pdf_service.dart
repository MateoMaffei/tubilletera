import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:tubilletera/model/cuota_estado.dart';
import 'package:tubilletera/model/gasto_terceros.dart';
import 'package:tubilletera/model/persona_terceros.dart';
import 'package:tubilletera/services/third_party_expense_calculator.dart';

class ThirdPartyPdfService {
  Future<Uint8List> buildResumenPdf({
    required List<PersonaTercero> personas,
    required Map<String, List<GastoTercero>> gastosPorPersona,
  }) async {
    final pdf = pw.Document();
    final date = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Resumen de deudas por persona',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Generado el ${date.toLocal()}'),
                pw.SizedBox(height: 16),
                ...personas.map((persona) {
                  final gastos = gastosPorPersona[persona.id] ?? <GastoTercero>[];
                  final totalAdeudado = ThirdPartyExpenseCalculator.totalAdeudadoPorPersona(gastos);
                  final totalPagado = ThirdPartyExpenseCalculator.totalPagadoPorPersona(gastos);
                  final totalPendiente = ThirdPartyExpenseCalculator.totalPendientePorPersona(gastos);

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        persona.nombreCompleto,
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      if (persona.email != null && persona.email!.isNotEmpty)
                        pw.Text('Email: ${persona.email!}'),
                      pw.SizedBox(height: 8),
                      pw.Text('Total adeudado: ${totalAdeudado.toStringAsFixed(2)} ARS'),
                      pw.Text('Total pagado: ${totalPagado.toStringAsFixed(2)} ARS'),
                      pw.Text('Total pendiente: ${totalPendiente.toStringAsFixed(2)} ARS'),
                      pw.SizedBox(height: 6),
                      if (gastos.isEmpty)
                        pw.Text('Sin gastos registrados.', style: const pw.TextStyle(fontStyle: pw.FontStyle.italic))
                      else
                        ...gastos.expand((gasto) {
                          return [
                            pw.Text(
                              'Gasto: ${gasto.montoTotal.toStringAsFixed(2)} ARS - ${gasto.cantidadCuotas} cuotas',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Column(
                              children: gasto.cuotas.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final cuota = entry.value;
                                final estado = cuota.estado == CuotaEstado.pagada ? 'Pagada' : 'Pendiente';
                                final vencida = cuota.estaVencida ? ' (Vencida)' : '';
                                final fecha = cuota.fechaVencimiento.toLocal();
                                final fechaTexto =
                                    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                  child: pw.Text(
                                    'Cuota $index: ${cuota.monto.toStringAsFixed(2)} ARS - '
                                    'Vence $fechaTexto - $estado$vencida',
                                  ),
                                );
                              }).toList(),
                            ),
                            pw.SizedBox(height: 8),
                          ];
                        }),
                      pw.Divider(),
                      pw.SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<File> guardarPdf(Uint8List bytes, {String? nombreArchivo}) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = nombreArchivo ?? 'reporte_gastos_terceros_$timestamp.pdf';
    final archivo = File('${directory.path}/$fileName');
    await archivo.writeAsBytes(bytes, flush: true);
    return archivo;
  }

  Future<void> compartirPdf(File archivo) async {
    await Share.shareXFiles([XFile(archivo.path)]);
  }
}
