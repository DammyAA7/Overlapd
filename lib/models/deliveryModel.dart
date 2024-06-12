import 'package:hive/hive.dart';
import 'geoPointAdapter.dart';

part 'deliveryModel.g.dart';

@HiveType(typeId: 1)
class DeliveryModel extends HiveObject {
  @HiveField(0)
  String deliveryAddress;

  @HiveField(1)
  GeoPointAdapter deliveryAddressCoordinates;

  @HiveField(2)
  String groceryStore;

  @HiveField(3)
  String placedBy;

  @HiveField(4)
  List<dynamic> itemsForDelivery;

  @HiveField(5)
  String itemTotal;

  @HiveField(6)
  String serviceFee;

  @HiveField(7)
  String deliveryFee;

  @HiveField(8)
  DateTime timeStamp;

  @HiveField(9)
  String status;

  @HiveField(10)
  String acceptedBy;

  @HiveField(11)
  String pickedUpBy;

  @HiveField(12)
  String delivererCode;

  @HiveField(13)
  bool delivered;

  @HiveField(14)
  bool complete;

  @HiveField(15)
  bool cancelled;

  @HiveField(16)
  String declinedBy;

  @HiveField(17)
  String paymentId;

  @HiveField(18)
  String? rewardCardUrl;

  @HiveField(19)
  String receipt;

  @HiveField(20)
  String orderNo;

  DeliveryModel({
    required this.deliveryAddress,
    required this.deliveryAddressCoordinates,
    required this.groceryStore,
    required this.placedBy,
    required this.itemsForDelivery,
    required this.itemTotal,
    required this.serviceFee,
    required this.deliveryFee,
    required this.timeStamp,
    required this.status,
    required this.acceptedBy,
    required this.pickedUpBy,
    required this.delivererCode,
    required this.delivered,
    required this.complete,
    required this.cancelled,
    required this.declinedBy,
    required this.paymentId,
    this.rewardCardUrl,
    required this.receipt,
    required this.orderNo,
  });
}
