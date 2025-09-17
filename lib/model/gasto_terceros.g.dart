// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto_terceros.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GastoTerceroAdapter extends TypeAdapter<GastoTercero> {
  @override
  final int typeId = 13;

  @override
  GastoTercero read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GastoTercero(
      id: fields[0] as String,
      personaId: fields[1] as String,
      montoTotal: fields[2] as double,
      cantidadCuotas: fields[3] as int,
      fechaPrimerVencimiento: fields[4] as DateTime,
      cuotas: (fields[5] as List).cast<CuotaTercero>(),
    );
  }

  @override
  void write(BinaryWriter writer, GastoTercero obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personaId)
      ..writeByte(2)
      ..write(obj.montoTotal)
      ..writeByte(3)
      ..write(obj.cantidadCuotas)
      ..writeByte(4)
      ..write(obj.fechaPrimerVencimiento)
      ..writeByte(5)
      ..write(obj.cuotas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GastoTerceroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
