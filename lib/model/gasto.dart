class Gasto {
  final String id;
  final String descripcion;
  final String idCategoria;
  final double monto;
  final DateTime fechaVencimiento;
  final DateTime fechaCreacion;
  final String? detalles;
  final bool estado;
  final String idUsuario;

  Gasto({
    required this.id,
    required this.descripcion,
    required this.idCategoria,
    required this.monto,
    required this.fechaVencimiento,
    required this.fechaCreacion,
    this.detalles,
    required this.estado,
    required this.idUsuario,
  });

  factory Gasto.fromMap(Map<String, dynamic> map) => Gasto(
        id: map['id'],
        descripcion: map['descripcion'],
        idCategoria: map['idCategoria'],
        monto: (map['monto'] as num).toDouble(),
        fechaVencimiento: DateTime.parse(map['fechaVencimiento']),
        fechaCreacion: DateTime.parse(map['fechaCreacion']),
        detalles: map['detalles'],
        estado: map['estado'],
        idUsuario: map['idUsuario'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'descripcion': descripcion,
        'idCategoria': idCategoria,
        'monto': monto,
        'fechaVencimiento': fechaVencimiento.toIso8601String(),
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'detalles': detalles,
        'estado': estado,
        'idUsuario': idUsuario,
      };
}
