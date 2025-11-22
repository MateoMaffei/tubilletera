import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:tubilletera/helpers/iconos_disponibles.dart';
import 'package:tubilletera/main_drawer.dart';
import 'package:tubilletera/model/categoria.dart';
import 'package:tubilletera/model/gasto.dart';
import 'package:tubilletera/pages/Gastos/gasto_form_page.dart';
import 'package:tubilletera/services/categoria_service_firebase.dart';
import 'package:tubilletera/services/gasto_service_firebase.dart';
import 'package:tubilletera/theme/app_colors.dart';

class GastosPage extends StatefulWidget {
  const GastosPage({super.key});

  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  final gastoService = GastoServiceFirebase();
  final categoriaService = CategoriaServiceFirebase();

  List<Categoria> categorias = [];

  bool modoSeleccion = false;
  final Set<String> gastosSeleccionados = {};

  DateTime selectedDate = DateTime.now();
  String? categoriaSeleccionada;
  bool? estadoSeleccionado;

  bool mostrarFiltros = false;

  DateTime tempDate = DateTime.now();
  String? tempCategoria;
  bool? tempEstado;

  final formatPeso = NumberFormat.currency(
    locale: 'es_AR',
    symbol: '',
    decimalDigits: 2);

  Stream<List<Gasto>> _filtrarGastos() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final inicioMes = DateTime(selectedDate.year, selectedDate.month, 1);
    final finMes = DateTime(selectedDate.year, selectedDate.month + 1, 1);

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('gastos')
        .doc(uid)
        .collection('items')
        .where('fechaVencimiento',
            isGreaterThanOrEqualTo: inicioMes.toIso8601String())
        .where('fechaVencimiento',
            isLessThan: finMes.toIso8601String());

    if (categoriaSeleccionada != null) {
      query = query.where('idCategoria', isEqualTo: categoriaSeleccionada);
    }
    if (estadoSeleccionado != null) {
      query = query.where('estado', isEqualTo: estadoSeleccionado);
    }

    return query.snapshots().map((snapshot) {
      final gastos =
          snapshot.docs.map((e) => Gasto.fromMap(e.data())).toList();
      gastos.sort((a, b) {
        if (a.estado != b.estado) {
          return a.estado ? 1 : -1;
        }
        return a.fechaVencimiento.compareTo(b.fechaVencimiento);
      });
      return gastos;
    });
  }

  void _confirmarCambioEstado(Gasto gasto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Desea confirmar el pago del gasto?'),
        content: Text(
          'Haciendo esto su gasto pasara a estado pago y ya no se sumara a las deudas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final actualizado = gasto.copyWith(estado: !gasto.estado);
              await gastoService.actualizar(actualizado);
              if (mounted) Navigator.pop(context);
              if (mounted) setState(() {});
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(Gasto gasto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text('¿Estás seguro de eliminar "${gasto.descripcion}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await gastoService.eliminar(gasto.id);
              if (mounted) Navigator.pop(context);
              if (mounted) setState(() {});
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmarDuplicar(Gasto gasto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Duplicar gasto?'),
        content: Text(
          '¿Querés copiar "${gasto.descripcion}" para el mes siguiente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoMes = DateTime(
                gasto.fechaVencimiento.year,
                gasto.fechaVencimiento.month + 1,
                gasto.fechaVencimiento.day,
              );
              final copia = gasto.copyWith(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                fechaVencimiento: nuevoMes,
                estado: false,
                fechaCreacion: DateTime.now(),
              );

              await gastoService.crear(copia);

              if (mounted) Navigator.pop(context);
              if (mounted) setState(() {});
            },
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );
  }

  void _activarModoSeleccion(Gasto gasto) {
    setState(() {
      modoSeleccion = true;
      gastosSeleccionados
        ..clear()
        ..add(gasto.id);
    });
  }

  void _toggleSeleccion(Gasto gasto) {
    setState(() {
      if (gastosSeleccionados.contains(gasto.id)) {
        gastosSeleccionados.remove(gasto.id);
        if (gastosSeleccionados.isEmpty) {
          modoSeleccion = false;
        }
      } else {
        gastosSeleccionados.add(gasto.id);
      }
    });
  }

  void _salirModoSeleccion() {
    setState(() {
      modoSeleccion = false;
      gastosSeleccionados.clear();
    });
  }

  double _totalSeleccionado(List<Gasto> gastos) {
    return gastos
        .where((g) => gastosSeleccionados.contains(g.id))
        .fold(0, (total, gasto) => total + gasto.monto);
  }

  Widget _buildGastoCard(Gasto gasto, Categoria categoria, bool seleccionado) {
    final ahora = DateTime.now();
    final diasRestantes = gasto.fechaVencimiento.difference(ahora).inDays;
    final estaVencido = diasRestantes < 0;

    // Color dinámico del monto
    Color colorImporte;
    if (gasto.estado) {
      colorImporte = AppColors.abonadoText;
    } else if (estaVencido) {
      colorImporte = AppColors.vencidoText;
    } else if (diasRestantes <= 5) {
      colorImporte = AppColors.porVencerText;
    } else {
      colorImporte = AppColors.pendienteText;
    }

    // Estado visual
    String estadoTexto = gasto.estado
        ? 'Abonado'
        : estaVencido
        ? 'Vencido'
        : diasRestantes <= 5
        ? 'Por vencer'
        : 'Pendiente';

    Color estadoColor = gasto.estado
        ? AppColors.abonadoText
        : estaVencido
        ? AppColors.vencidoText
        : diasRestantes <= 5
        ? AppColors.porVencerText
        : AppColors.pendienteText;

    return GestureDetector(
      onLongPress: () {
        if (modoSeleccion) {
          _toggleSeleccion(gasto);
        } else {
          _activarModoSeleccion(gasto);
        }
      },
      onTap: () {
        if (modoSeleccion) {
          _toggleSeleccion(gasto);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: seleccionado
              ? Border.all(color: AppColors.secondaryButton, width: 1.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (modoSeleccion)
                Align(
                  alignment: Alignment.centerRight,
                  child: Checkbox(
                    value: seleccionado,
                    onChanged: (_) => _toggleSeleccion(gasto),
                    activeColor: AppColors.secondaryButton,
                  ),
                ),
            // Categoría e ícono
            Row(
              children: [
                Icon(
                  IconHelper.iconList[categoria.icono] ?? Icons.category,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  categoria.descripcion,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estadoTexto,
                    style: TextStyle(
                      fontSize: 12,
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) async {
                    switch (value) {
                      case 'editar':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GastoFormPage(gasto: gasto),
                          ),
                        ).then((_) => setState(() {}));
                        break;
                      case 'estado':
                        _confirmarCambioEstado(gasto);
                        break;
                      case 'duplicar':
                        _confirmarDuplicar(gasto);
                        break;
                      case 'eliminar':
                        _confirmarEliminar(gasto);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      enabled: gasto.estado == true ? false : true,
                      value: 'estado',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: gasto.estado == true ? Colors.lightGreen : Colors.green),
                          const SizedBox(width: 8),
                          Text('Pagar', style: TextStyle(color: gasto.estado == true ? Colors.lightGreen : Colors.green)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.purple),
                          SizedBox(width: 8),
                          Text(
                            'Editar',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duplicar',
                      child: Row(
                        children: const [
                          Icon(Icons.copy, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Copiar',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Descripción y monto
            Row(
              children: [
                Expanded(
                  child: Text(
                    gasto.descripcion,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '\$ ${formatPeso.format(gasto.monto)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorImporte,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Fecha de vencimiento
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vence: ${DateFormat('dd/MM/yyyy').format(gasto.fechaVencimiento)}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                TextButton.icon(
                  icon: const Icon(
                    Icons.visibility,
                    size: 20,
                    color: Colors.blue,
                  ),
                  label: const Text(
                    'Detalles',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    minimumSize: const Size(0, 30),
                  ),
                  onPressed: () => _mostrarDetallesDialog(gasto),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _mostrarDetallesDialog(Gasto gasto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(gasto.descripcion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gasto.detalles?.isNotEmpty == true) ...[
              const Text(
                'Detalles:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(gasto.detalles!),
              const SizedBox(height: 8),
            ],
            Text(
              'Fecha de creación: ${DateFormat('dd/MM/yyyy').format(gasto.fechaCreacion)}',
            ),
            Text(
              'Fecha de vencimiento: ${DateFormat('dd/MM/yyyy').format(gasto.fechaVencimiento)}',
            ),
            Text('Estado: ${gasto.estado ? "Abonado" : "Pendiente"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  List<Gasto> _gastosPendientes(List<Gasto> todos) {
    final pendientes = todos
        .where((g) => !g.estado)
        .toList()
      ..sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return pendientes;
  }

  List<Gasto> _gastosAbonados(List<Gasto> todos) {
    final abonados = todos
        .where((g) => g.estado)
        .toList()
      ..sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return abonados;
  }

  Categoria _buscarCategoria(String id) {
    return categorias.firstWhere(
      (cat) => cat.id == id,
      orElse: () => Categoria(id: '', descripcion: 'Desconocida', icono: ''),
    );
  }


  @override
  void initState() {
    super.initState();
    tempDate = selectedDate;
    tempCategoria = categoriaSeleccionada;
    tempEstado = estadoSeleccionado;
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    categorias = await categoriaService.obtenerTodas();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Gasto>>(
      stream: _filtrarGastos(),
      builder: (context, snapshot) {
        final gastos = snapshot.data ?? [];
        final pendientes = _gastosPendientes(gastos);
        final abonados = _gastosAbonados(gastos);
        final totalSeleccionado = _totalSeleccionado(gastos);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gastos', style: TextStyle( color: AppColors.secondaryButtonText),),
            actions: [
              if (modoSeleccion)
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.secondaryButtonText,
                  onPressed: _salirModoSeleccion,
                ),
              IconButton(
                icon: Icon(
                  mostrarFiltros ? Icons.filter_alt_off : Icons.filter_alt,
                ),
                color: AppColors.secondaryButtonText,
                onPressed: () => setState(() => mostrarFiltros = !mostrarFiltros),
              ),
            ],
          ),
          drawer: const MainDrawer(currentRoute: '/gastos'),
          body: Column(
            children: [
              AnimatedCrossFade(
                crossFadeState:
                    mostrarFiltros ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
                firstChild: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await showMonthPicker(
                            context: context,
                            initialDate: tempDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100)
                          );
                          if (picked != null) {
                            setState(() => tempDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(DateFormat('MMMM yyyy', 'es_ES').format(selectedDate).toUpperCase()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String?>(
                        isExpanded: true,
                        value: tempCategoria,
                        hint: const Text('Todas las categorías'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todas')),
                          ...categorias.map((cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.descripcion),
                              )),
                        ],
                        onChanged: (value) => setState(() => tempCategoria = value),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<bool?>(
                        isExpanded: true,
                        value: tempEstado,
                        hint: const Text('Estado'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: true, child: Text('Abonados')),
                          DropdownMenuItem(value: false, child: Text('Pendientes')),
                        ],
                        onChanged: (value) => setState(() => tempEstado = value),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedDate = tempDate;
                            categoriaSeleccionada = tempCategoria;
                            estadoSeleccionado = tempEstado;
                          });
                        },
                        icon: const Icon(Icons.filter_alt, color: Colors.black87),
                        label: const Text('Aplicar filtros', style: TextStyle(color: Colors.black87)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
              const Divider(height: 1),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          ...pendientes.map((gasto) {
                            final categoria = _buscarCategoria(gasto.idCategoria);
                            final seleccionado =
                                gastosSeleccionados.contains(gasto.id);
                            return _buildGastoCard(gasto, categoria, seleccionado);
                          }),
                          if (abonados.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: const [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      'Abonados',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                            ),
                            ...abonados.map((gasto) {
                              final categoria = _buscarCategoria(gasto.idCategoria);
                              final seleccionado =
                                  gastosSeleccionados.contains(gasto.id);
                              return _buildGastoCard(gasto, categoria, seleccionado);
                            }),
                          ],
                          if (modoSeleccion)
                            const SizedBox(height: 80),
                        ],
                      ),
              ),

            ],
          ),
          bottomNavigationBar: modoSeleccion
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total seleccionado:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$ ${formatPeso.format(totalSeleccionado)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryButton,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push<Gasto?>(
                context,
                MaterialPageRoute(builder: (_) => const GastoFormPage()),
              );
              setState(() {}); // Refresca la lista
            },
            backgroundColor: AppColors.secondaryButton,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
