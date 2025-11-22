// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingreso_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IngresoAdapter extends TypeAdapter<Ingreso> {
  @override
  final int typeId = 2;

  @override
  Ingreso read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingreso(
      id: fields[0] as String,
      nombreDeudor: fields[1] as String,
      monto: fields[2] as double,
      fechaVencimiento: fields[3] as DateTime,
      estado: fields[4] as bool,
      fechaCreacion: fields[5] as DateTime,
      detalles: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Ingreso obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombreDeudor)
      ..writeByte(2)
      ..write(obj.monto)
      ..writeByte(3)
      ..write(obj.fechaVencimiento)
      ..writeByte(4)
      ..write(obj.estado)
      ..writeByte(5)
      ..write(obj.fechaCreacion)
      ..writeByte(6)
      ..write(obj.detalles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngresoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
