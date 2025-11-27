// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuota_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CuotaAdapter extends TypeAdapter<Cuota> {
  @override
  final int typeId = 5;

  @override
  Cuota read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cuota(
      id: fields[0] as String,
      planCuotasId: fields[1] as String,
      numeroCuota: fields[2] as int,
      montoCuota: fields[3] as double,
      fechaVencimiento: fields[4] as DateTime,
      pagada: fields[5] as bool,
      fechaPago: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Cuota obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.planCuotasId)
      ..writeByte(2)
      ..write(obj.numeroCuota)
      ..writeByte(3)
      ..write(obj.montoCuota)
      ..writeByte(4)
      ..write(obj.fechaVencimiento)
      ..writeByte(5)
      ..write(obj.pagada)
      ..writeByte(6)
      ..write(obj.fechaPago);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CuotaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
