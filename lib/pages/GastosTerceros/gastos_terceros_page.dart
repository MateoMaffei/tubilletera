import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/gasto_terceros.dart';
import 'package:tubilletera/model/persona_terceros.dart';
import 'package:tubilletera/pages/GastosTerceros/gasto_tercero_form_page.dart';
import 'package:tubilletera/pages/GastosTerceros/persona_tercero_form_page.dart';
import 'package:tubilletera/pages/GastosTerceros/widgets/gasto_tercero_card.dart';
import 'package:tubilletera/providers/third_party_expenses_provider.dart';

class GastosTercerosPage extends StatefulWidget {
  const GastosTercerosPage({super.key});

  @override
  State<GastosTercerosPage> createState() => _GastosTercerosPageState();
}

class _GastosTercerosPageState extends State<GastosTercerosPage> {
  bool _exportando = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThirdPartyExpensesProvider>();
    final personas = provider.personas;
    final moneda = NumberFormat.currency(locale: 'es_AR', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos de Terceros'),
        actions: [
          IconButton(
            onPressed: _exportando ? null : () => _generarReporte(provider),
            icon: _exportando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Generar reporte PDF',
          ),
          IconButton(
            onPressed: () => _abrirFormularioPersona(),
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Agregar persona',
          ),
        ],
      ),
      drawer: MainDrawer(currentRoute: '/gastos-terceros'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioGasto(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),
      body: personas.isEmpty
          ? const Center(
              child: Text('No hay personas cargadas. Agregá una para registrar gastos.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: personas.length,
              itemBuilder: (context, index) {
                final persona = personas[index];
                final gastos = provider.gastosPorPersona(persona.id);
                final totalAdeudado = provider.totalAdeudadoPersona(persona.id);
                final totalPagado = provider.totalPagadoPersona(persona.id);
                final totalPendiente = provider.totalPendientePersona(persona.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(persona.nombreCompleto),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (persona.email != null) Text(persona.email!),
                        Text('Total adeudado: ${moneda.format(totalAdeudado)}'),
                        Text('Pagado: ${moneda.format(totalPagado)} · Pendiente: ${moneda.format(totalPendiente)}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _abrirFormularioPersona(persona: persona);
                        } else if (value == 'delete') {
                          _confirmarEliminarPersona(persona);
                        } else if (value == 'add-expense') {
                          _abrirFormularioGasto(persona: persona);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'add-expense', child: Text('Nuevo gasto')),
                        PopupMenuItem(value: 'edit', child: Text('Editar persona')),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar persona')),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () => _abrirFormularioGasto(persona: persona),
                            icon: const Icon(Icons.add),
                            label: const Text('Registrar gasto'),
                          ),
                        ),
                      ),
                      if (gastos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Sin gastos registrados para esta persona.'),
                        )
                      else
                        ...gastos.map(
                          (gasto) => GastoTerceroCard(
                            gasto: gasto,
                            onEditar: () => _abrirFormularioGasto(persona: persona, gasto: gasto),
                            onEliminar: () => _confirmarEliminarGasto(gasto),
                            onToggleCuota: (cuotaId, pagada) =>
                                provider.marcarCuota(gasto.id, cuotaId, pagada),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _abrirFormularioPersona({PersonaTercero? persona}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonaTerceroFormPage(persona: persona),
      ),
    );
    if (mounted) {
      context.read<ThirdPartyExpensesProvider>().cargarDatos();
    }
  }

  Future<void> _abrirFormularioGasto({PersonaTercero? persona, GastoTercero? gasto}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GastoTerceroFormPage(
          personaPreseleccionada: persona,
          gasto: gasto,
        ),
      ),
    );
    if (mounted) {
      context.read<ThirdPartyExpensesProvider>().cargarDatos();
    }
  }

  Future<void> _confirmarEliminarPersona(PersonaTercero persona) async {
    final provider = context.read<ThirdPartyExpensesProvider>();
    final gastosAsociados = provider.gastosPorPersona(persona.id);
    final eliminar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: Text(
          gastosAsociados.isEmpty
              ? '¿Desea eliminar a ${persona.nombreCompleto}?'
              : 'La persona tiene ${gastosAsociados.length} gastos asociados. ¿Desea eliminarlos también?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (eliminar == true) {
      await provider.eliminarPersona(persona, eliminarGastos: gastosAsociados.isNotEmpty);
    }
  }

  Future<void> _confirmarEliminarGasto(GastoTercero gasto) async {
    final provider = context.read<ThirdPartyExpensesProvider>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: const Text('¿Desea eliminar este gasto y sus cuotas asociadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await provider.eliminarGasto(gasto.id);
    }
  }

  Future<void> _generarReporte(ThirdPartyExpensesProvider provider) async {
    setState(() => _exportando = true);
    try {
      final resultado = await provider.generarReportePdf();
      final archivo = resultado['file'] as File;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte guardado en ${archivo.path}'),
          action: SnackBarAction(
            label: 'Compartir',
            onPressed: () => provider.compartirReporte(archivo),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el reporte: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _exportando = false);
      }
    }
  }
}
