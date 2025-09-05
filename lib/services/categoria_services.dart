import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../model/categoria_hive.dart';

class CategoriaService {
  final Box<Categoria> _box = Hive.box<Categoria>('categoriasBox');
  final _uuid = const Uuid();

  /// Obtener todas las categorías
  List<Categoria> obtenerTodas() {
    return _box.values.toList();
  }

  /// Obtener una categoría por ID
  Categoria? obtenerPorId(String id) {
    return _box.values.firstWhereOrNull((cat) => cat.id == id);
  }

  /// Crear una nueva categoría
  Future<void> crearCategoria(String descripcion, String icono, String idUsuario) async {
    final nuevaCategoria = Categoria(
      id: _uuid.v4(),
      // idUsuario: idUsuario,
      descripcion: descripcion,
      icono: icono,
    );
    await _box.add(nuevaCategoria);
  }

  /// Actualizar una categoría existente
  Future<void> actualizarCategoria(String id, String nuevaDescripcion, String nuevoIcono) async {
    final categoria = _box.values.firstWhereOrNull((cat) => cat.id == id);
    if (categoria != null) {
      categoria.descripcion = nuevaDescripcion;
      categoria.icono = nuevoIcono;
      await categoria.save();
    }
  }

  /// Eliminar una categoría por ID
  Future<void> eliminarCategoria(String id) async {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == id,
      orElse: () => null,
    );
    if (key != null) {
      await _box.delete(key);
    }
  }
}
