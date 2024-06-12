// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveryModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryModelAdapter extends TypeAdapter<DeliveryModel> {
  @override
  final int typeId = 1;

  @override
  DeliveryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryModel(
      deliveryAddress: fields[0] as String,
      deliveryAddressCoordinates: fields[1] as GeoPointAdapter,
      groceryStore: fields[2] as String,
      placedBy: fields[3] as String,
      itemsForDelivery: (fields[4] as List).cast<dynamic>(),
      itemTotal: fields[5] as String,
      serviceFee: fields[6] as String,
      deliveryFee: fields[7] as String,
      timeStamp: fields[8] as DateTime,
      status: fields[9] as String,
      acceptedBy: fields[10] as String,
      pickedUpBy: fields[11] as String,
      delivererCode: fields[12] as String,
      delivered: fields[13] as bool,
      complete: fields[14] as bool,
      cancelled: fields[15] as bool,
      declinedBy: fields[16] as String,
      paymentId: fields[17] as String,
      rewardCardUrl: fields[18] as String?,
      receipt: fields[19] as String,
      orderNo: fields[20] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.deliveryAddress)
      ..writeByte(1)
      ..write(obj.deliveryAddressCoordinates)
      ..writeByte(2)
      ..write(obj.groceryStore)
      ..writeByte(3)
      ..write(obj.placedBy)
      ..writeByte(4)
      ..write(obj.itemsForDelivery)
      ..writeByte(5)
      ..write(obj.itemTotal)
      ..writeByte(6)
      ..write(obj.serviceFee)
      ..writeByte(7)
      ..write(obj.deliveryFee)
      ..writeByte(8)
      ..write(obj.timeStamp)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.acceptedBy)
      ..writeByte(11)
      ..write(obj.pickedUpBy)
      ..writeByte(12)
      ..write(obj.delivererCode)
      ..writeByte(13)
      ..write(obj.delivered)
      ..writeByte(14)
      ..write(obj.complete)
      ..writeByte(15)
      ..write(obj.cancelled)
      ..writeByte(16)
      ..write(obj.declinedBy)
      ..writeByte(17)
      ..write(obj.paymentId)
      ..writeByte(18)
      ..write(obj.rewardCardUrl)
      ..writeByte(19)
      ..write(obj.receipt)
      ..writeByte(20)
      ..write(obj.orderNo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
