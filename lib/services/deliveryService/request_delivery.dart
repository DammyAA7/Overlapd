class DeliveryInfo {
  late final String userID;
  late final String userName;

  DeliveryInfo({required this.userID, required this.userName});

  Map<String, dynamic> toMap() {
    return {'userId': userID, 'userName': userName};
  }
}
