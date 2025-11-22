// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_cuotas_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlanCuotasAdapter extends TypeAdapter<PlanCuotas> {
  @override
  final int typeId = 4;

  @override
  PlanCuotas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlanCuotas(
      id: fields[0] as String,
      deudorId: fields[1] as String,
      nombreGasto: fields[2] as String,
      montoTotal: fields[3] as double,
      cantidadTotalCuotas: fields[4] as int,
      fechaInicio: fields[5] as DateTime,
      cuotasPagadasIniciales: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlanCuotas obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deudorId)
      ..writeByte(2)
      ..write(obj.nombreGasto)
      ..writeByte(3)
      ..write(obj.montoTotal)
      ..writeByte(4)
      ..write(obj.cantidadTotalCuotas)
      ..writeByte(5)
      ..write(obj.fechaInicio)
      ..writeByte(6)
      ..write(obj.cuotasPagadasIniciales);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanCuotasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
