// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona_terceros.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonaTerceroAdapter extends TypeAdapter<PersonaTercero> {
  @override
  final int typeId = 12;

  @override
  PersonaTercero read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonaTercero(
      id: fields[0] as String,
      nombre: fields[1] as String,
      apellido: fields[2] as String,
      email: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PersonaTercero obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.apellido)
      ..writeByte(3)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonaTerceroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
