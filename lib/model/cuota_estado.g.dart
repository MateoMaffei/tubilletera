// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuota_estado.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CuotaEstadoAdapter extends TypeAdapter<CuotaEstado> {
  @override
  final int typeId = 10;

  @override
  CuotaEstado read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CuotaEstado.pendiente;
      case 1:
        return CuotaEstado.pagada;
      default:
        return CuotaEstado.pendiente;
    }
  }

  @override
  void write(BinaryWriter writer, CuotaEstado obj) {
    switch (obj) {
      case CuotaEstado.pendiente:
        writer.writeByte(0);
        break;
      case CuotaEstado.pagada:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CuotaEstadoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
