// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deudor_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeudorAdapter extends TypeAdapter<Deudor> {
  @override
  final int typeId = 3;

  @override
  Deudor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Deudor(
      id: fields[0] as String,
      nombre: fields[1] as String,
      telefono: fields[2] as String?,
      nota: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Deudor obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.telefono)
      ..writeByte(3)
      ..write(obj.nota);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeudorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
