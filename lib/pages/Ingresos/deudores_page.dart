import 'package:flutter/material.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/deudor_hive.dart';
import 'package:tubilletera/services/deudor_services.dart';

class DeudoresPage extends StatefulWidget {
  const DeudoresPage({super.key});

  @override
  State<DeudoresPage> createState() => _DeudoresPageState();
}

class _DeudoresPageState extends State<DeudoresPage> {
  final deudorService = DeudorService();

  void _mostrarDialogo({Deudor? deudor}) {
    final nombreController = TextEditingController(text: deudor?.nombre ?? '');
    final telefonoController = TextEditingController(text: deudor?.telefono ?? '');
    final notaController = TextEditingController(text: deudor?.nota ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(deudor == null ? 'Nuevo deudor' : 'Editar deudor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
              ),
              TextField(
                controller: notaController,
                decoration: const InputDecoration(labelText: 'Nota (opcional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreController.text.trim();
              if (nombre.isEmpty) return;

              if (deudor == null) {
                await deudorService.crearDeudor(
                  nombre: nombre,
                  telefono: telefonoController.text.trim().isEmpty
                      ? null
                      : telefonoController.text.trim(),
                  nota: notaController.text.trim().isEmpty ? null : notaController.text.trim(),
                );
              } else {
                await deudorService.actualizarDeudor(
                  deudor,
                  nombre: nombre,
                  telefono: telefonoController.text.trim().isEmpty
                      ? null
                      : telefonoController.text.trim(),
                  nota: notaController.text.trim().isEmpty ? null : notaController.text.trim(),
                );
              }

              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(Deudor deudor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar deudor'),
        content: Text('¿Estás seguro de eliminar "${deudor.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await deudorService.eliminarDeudor(deudor.id);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deudores = deudorService.obtenerTodos();

    return Scaffold(
      appBar: AppBar(title: const Text('Deudores')),
      drawer: const MainDrawer(currentRoute: '/deudores'),
      body: deudores.isEmpty
          ? const Center(child: Text('No hay deudores cargados'))
          : ListView.builder(
              itemCount: deudores.length,
              itemBuilder: (_, index) {
                final deudor = deudores[index];
                return ListTile(
                  leading: const Icon(Icons.person_outline, color: Colors.green),
                  title: Text(deudor.nombre),
                  subtitle: deudor.telefono != null ? Text(deudor.telefono!) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _mostrarDialogo(deudor: deudor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmarEliminar(deudor),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogo(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
