// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuota_terceros.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CuotaTerceroAdapter extends TypeAdapter<CuotaTercero> {
  @override
  final int typeId = 11;

  @override
  CuotaTercero read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CuotaTercero(
      id: fields[0] as String,
      monto: fields[1] as double,
      fechaVencimiento: fields[2] as DateTime,
      estado: fields[3] as CuotaEstado,
    );
  }

  @override
  void write(BinaryWriter writer, CuotaTercero obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.monto)
      ..writeByte(2)
      ..write(obj.fechaVencimiento)
      ..writeByte(3)
      ..write(obj.estado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CuotaTerceroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
