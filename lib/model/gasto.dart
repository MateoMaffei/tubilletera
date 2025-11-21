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

  Gasto copyWith({
    String? id,
    String? descripcion,
    String? idCategoria,
    double? monto,
    DateTime? fechaVencimiento,
    DateTime? fechaCreacion,
    String? detalles,
    bool? estado,
    String? idUsuario,
  }) {
    return Gasto(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      idCategoria: idCategoria ?? this.idCategoria,
      monto: monto ?? this.monto,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      detalles: detalles ?? this.detalles,
      estado: estado ?? this.estado,
      idUsuario: idUsuario ?? this.idUsuario,
    );
  }
}
