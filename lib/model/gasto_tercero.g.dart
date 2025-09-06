// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto_tercero_hive.dart';

class GastoTerceroAdapter extends TypeAdapter<GastoTercero> {
  @override
  final int typeId = 2;

  @override
  GastoTercero read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GastoTercero(
      id: fields[0] as String,
      persona: fields[1] as String,
      montoTotal: fields[2] as double,
      cantidadCuotas: fields[3] as int,
      montoPorCuota: fields[4] as double,
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
      ..write(obj.persona)
      ..writeByte(2)
      ..write(obj.montoTotal)
      ..writeByte(3)
      ..write(obj.cantidadCuotas)
      ..writeByte(4)
      ..write(obj.montoPorCuota)
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

class CuotaTerceroAdapter extends TypeAdapter<CuotaTercero> {
  @override
  final int typeId = 3;

  @override
  CuotaTercero read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CuotaTercero(
      numero: fields[0] as int,
      fechaVencimiento: fields[1] as DateTime,
      monto: fields[2] as double,
      pagada: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CuotaTercero obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.numero)
      ..writeByte(1)
      ..write(obj.fechaVencimiento)
      ..writeByte(2)
      ..write(obj.monto)
      ..writeByte(3)
      ..write(obj.pagada);
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
