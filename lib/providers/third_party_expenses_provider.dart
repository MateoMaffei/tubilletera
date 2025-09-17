import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:tubilletera/model/cuota_estado.dart';
import 'package:tubilletera/model/gasto_terceros.dart';
import 'package:tubilletera/model/persona_terceros.dart';
import 'package:tubilletera/services/third_party_expense_calculator.dart';
import 'package:tubilletera/services/third_party_expense_service.dart';
import 'package:tubilletera/services/third_party_person_service.dart';
import 'package:tubilletera/services/third_party_pdf_service.dart';

class ThirdPartyExpensesProvider extends ChangeNotifier {
  ThirdPartyExpensesProvider({
    ThirdPartyPersonService? personService,
    ThirdPartyExpenseService? expenseService,
    ThirdPartyPdfService? pdfService,
  })  : _personService = personService ?? ThirdPartyPersonService(),
        _expenseService = expenseService ?? ThirdPartyExpenseService(),
        _pdfService = pdfService ?? ThirdPartyPdfService();

  final ThirdPartyPersonService _personService;
  final ThirdPartyExpenseService _expenseService;
  final ThirdPartyPdfService _pdfService;
  final _uuid = const Uuid();

  final List<PersonaTercero> _personas = [];
  final List<GastoTercero> _gastos = [];

  UnmodifiableListView<PersonaTercero> get personas => UnmodifiableListView(_personas);

  void cargarDatos() {
    _personas
      ..clear()
      ..addAll(_personService.obtenerPersonas());
    _gastos
      ..clear()
      ..addAll(_expenseService.obtenerGastos());
    notifyListeners();
  }

  List<GastoTercero> gastosPorPersona(String personaId) {
    return _gastos.where((gasto) => gasto.personaId == personaId).toList()
      ..sort((a, b) => a.fechaPrimerVencimiento.compareTo(b.fechaPrimerVencimiento));
  }

  double totalAdeudadoPersona(String personaId) {
    return ThirdPartyExpenseCalculator.totalAdeudadoPorPersona(gastosPorPersona(personaId));
  }

  double totalPagadoPersona(String personaId) {
    return ThirdPartyExpenseCalculator.totalPagadoPorPersona(gastosPorPersona(personaId));
  }

  double totalPendientePersona(String personaId) {
    return ThirdPartyExpenseCalculator.totalPendientePorPersona(gastosPorPersona(personaId));
  }

  Future<void> guardarPersona({
    String? id,
    required String nombre,
    required String apellido,
    String? email,
  }) async {
    final emailNormalizado = (email ?? '').trim();
    final persona = PersonaTercero(
      id: id ?? _uuid.v4(),
      nombre: nombre,
      apellido: apellido,
      email: emailNormalizado.isEmpty ? null : emailNormalizado,
    );

    await _personService.guardarPersona(persona);
    final index = _personas.indexWhere((p) => p.id == persona.id);
    if (index >= 0) {
      _personas[index] = persona;
    } else {
      _personas.add(persona);
      _personas.sort((a, b) => a.nombreCompleto.compareTo(b.nombreCompleto));
    }
    notifyListeners();
  }

  Future<void> eliminarPersona(PersonaTercero persona, {bool eliminarGastos = false}) async {
    await _personService.eliminarPersona(persona.id);
    _personas.removeWhere((p) => p.id == persona.id);

    if (eliminarGastos) {
      final asociados = _gastos.where((gasto) => gasto.personaId == persona.id).toList();
      for (final gasto in asociados) {
        await _expenseService.eliminarGasto(gasto.id);
        _gastos.remove(gasto);
      }
    } else {
      _gastos.removeWhere((gasto) => gasto.personaId == persona.id);
    }
    notifyListeners();
  }

  Future<void> registrarGasto({
    String? id,
    required String personaId,
    required double montoTotal,
    required int cantidadCuotas,
    required DateTime fechaPrimerVencimiento,
    double? montoPorCuota,
  }) async {
    final totalNormalizado = double.parse(montoTotal.toStringAsFixed(2));

    final cuotas = ThirdPartyExpenseCalculator.generarCuotas(
      montoTotal: totalNormalizado,
      cantidadCuotas: cantidadCuotas,
      fechaPrimerVencimiento: fechaPrimerVencimiento,
      montoPorCuota: montoPorCuota,
    );

    final gasto = GastoTercero(
      id: id ?? _uuid.v4(),
      personaId: personaId,
      montoTotal: totalNormalizado,
      cantidadCuotas: cantidadCuotas,
      fechaPrimerVencimiento: fechaPrimerVencimiento,
      cuotas: cuotas,
    );

    await _expenseService.guardarGasto(gasto);
    final index = _gastos.indexWhere((element) => element.id == gasto.id);
    if (index >= 0) {
      _gastos[index] = gasto;
    } else {
      _gastos.add(gasto);
    }
    _gastos.sort((a, b) => a.fechaPrimerVencimiento.compareTo(b.fechaPrimerVencimiento));
    notifyListeners();
  }

  Future<void> eliminarGasto(String gastoId) async {
    await _expenseService.eliminarGasto(gastoId);
    _gastos.removeWhere((gasto) => gasto.id == gastoId);
    notifyListeners();
  }

  Future<void> marcarCuota(String gastoId, String cuotaId, bool pagada) async {
    final gasto = _gastos.firstWhere((element) => element.id == gastoId);
    final cuota = gasto.cuotas.firstWhere((element) => element.id == cuotaId);
    cuota.estado = pagada ? CuotaEstado.pagada : CuotaEstado.pendiente;
    await gasto.save();
    notifyListeners();
  }

  Future<Map<String, dynamic>> generarReportePdf() async {
    final mapa = <String, List<GastoTercero>>{};
    for (final persona in _personas) {
      mapa[persona.id] = gastosPorPersona(persona.id);
    }
    final bytes = await _pdfService.buildResumenPdf(personas: _personas, gastosPorPersona: mapa);
    final archivo = await _pdfService.guardarPdf(bytes);
    return {'bytes': bytes, 'file': archivo};
  }

  Future<void> compartirReporte(File archivo) async {
    await _pdfService.compartirPdf(archivo);
  }
}
