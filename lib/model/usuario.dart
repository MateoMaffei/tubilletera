class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final DateTime? fechaNacimiento;
  final double? sueldo;
  final bool biometria;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.fechaNacimiento,
    this.sueldo,
    required this.biometria,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id: map['id'],
    nombre: map['nombre'],
    apellido: map['apellido'],
    email: map['email'],
    fechaNacimiento: map['fechaNacimiento'] != null
        ? DateTime.parse(map['fechaNacimiento'])
        : null,
    sueldo: map['sueldo']?.toDouble(),
    biometria: map['biometria'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    'fechaNacimiento': fechaNacimiento?.toIso8601String(),
    'sueldo': sueldo,
    'biometria': biometria,
  };
}
