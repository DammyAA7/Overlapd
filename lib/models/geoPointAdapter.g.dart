// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geoPointAdapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeoPointAdapterAdapter extends TypeAdapter<GeoPointAdapter> {
  @override
  final int typeId = 2;

  @override
  GeoPointAdapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeoPointAdapter(
      fields[0] as double,
      fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GeoPointAdapter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPointAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
