// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GastoAdapter extends TypeAdapter<Gasto> {
  @override
  final int typeId = 1;

  @override
  Gasto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gasto(
      id: fields[0] as String,
      descripcion: fields[1] as String,
      idCategoria: fields[2] as String,
      monto: fields[3] as double,
      fechaVencimiento: fields[4] as DateTime,
      detalles: fields[5] as String?,
      estado: fields[6] as bool,
      fechaCreacion: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Gasto obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.descripcion)
      ..writeByte(2)
      ..write(obj.idCategoria)
      ..writeByte(3)
      ..write(obj.monto)
      ..writeByte(4)
      ..write(obj.fechaVencimiento)
      ..writeByte(5)
      ..write(obj.detalles)
      ..writeByte(6)
      ..write(obj.estado)
      ..writeByte(7)
      ..write(obj.fechaCreacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GastoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
