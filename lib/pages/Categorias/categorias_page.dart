// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tubilletera/helpers/iconos_disponibles.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/categoria_hive.dart';
import 'package:tubilletera/services/categoria_service_firebase.dart';
import 'package:tubilletera/services/categoria_services.dart';
import 'package:uuid/uuid.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  // final categoriaService = CategoriaServiceFirebase();
  final categoriaService = CategoriaService();
  final _uuid = const Uuid();

  void _mostrarDialogoCategoria({Categoria? categoriaExistente}) {
    final descripcionController = TextEditingController(
      text: categoriaExistente?.descripcion ?? '',
    );
    String iconoSeleccionado =
        categoriaExistente?.icono ?? IconHelper.iconList.keys.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                categoriaExistente == null
                    ? 'Nueva Categoría'
                    : 'Editar Categoría',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Seleccionar ícono:'),
                  SizedBox(
                    height: 230,
                    width: 230,
                    child: GridView.count(
                      crossAxisCount: 5,
                      children: IconHelper.iconList.entries.map((entry) {
                        final selected = entry.key == iconoSeleccionado;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              iconoSeleccionado = entry.key;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.green.withOpacity(0.2)
                                  : null,
                              border: Border.all(
                                color: selected ? Colors.green : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              entry.value,
                              color: selected ? Colors.green : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final desc = descripcionController.text.trim();

                    if (desc.isEmpty) return;

                    if (categoriaExistente == null) {
                      await categoriaService.crearCategoria(
                          desc,
                          iconoSeleccionado,
                          _uuid.v4().toString()
                          );
                    } else {
                      await categoriaService.actualizarCategoria(
                          categoriaExistente.id,desc,iconoSeleccionado,
                          // idUsuario: FirebaseAuth.instance.currentUser!.uid
                      );
                    }

                    if (mounted) Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminar(Categoria categoria) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Estás seguro de eliminar "${categoria.descripcion}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await categoriaService.eliminarCategoria(categoria.id);
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = categoriaService.obtenerTodas();

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      drawer: const MainDrawer(currentRoute: '/categorias'),
      body: categorias.isEmpty
          ? const Center(child: Text('No hay categorías aún'))
          : ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (_, index) {
                final categoria = categorias[index];

                return ListTile(
                  leading: Icon(
                    IconHelper.iconList[categoria.icono] ?? Icons.help_outline,
                    color: Colors.green,
                  ),
                  title: Text(categoria.descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _mostrarDialogoCategoria(
                          categoriaExistente: categoria,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmarEliminar(categoria),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCategoria(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
