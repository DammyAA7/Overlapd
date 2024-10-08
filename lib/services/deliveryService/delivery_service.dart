import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../storeService/groceryRange.dart';
import '../userAuthService/firebase_auth_implementation/firebase_auth_services.dart';

class DeliveryService extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();

  Future<void> acceptDelivery(String deliveryAddress, String userId, String placedBy, String orderId) async{
    final details = {
      'Delivery Address': deliveryAddress,
      'Placed by': placedBy,
      'Time Stamp': DateTime.now(),
      'complete': 'no',
      'cancelled': 'no',
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Accepted Deliveries')
        .doc(orderId)
        .set(details);

  }
  Future<void> openDelivery(String address, GeoPoint coordinates, String storeName, List productList, String total, String paymentID, String? rewardCardUrl,  String serviceFee, String deliveryFee) async {
    final userId = _auth.getUserId();
    String orderNo;

    final public = {
      'Delivery Address': address,
      'Delivery Address Coordinates': coordinates,
      'Grocery Store': storeName,
      'Placed by': userId,
      'Items for Delivery': productList,
      'Item Total' : total,
      'Service fee': serviceFee,
      'delivery fee': deliveryFee,
      'Time Stamp': DateTime.now(),
      'status': 'Order Requested',
      'accepted by' : 'N/A',
      'picked up by': 'N/A',
      'deliverer code': '',
      'delivered': false,
      'complete': false,
      'cancelled': false,
      'declined By': '',
      'payment id': paymentID,
      'reward card': rewardCardUrl,
      'receipt':'N/A'
    };
    final orderInfoDocRef = await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .add(public);
    orderNo = orderInfoDocRef.id;

    final private = {
      'Grocery Store': storeName,
      'Delivery Address': address,
      'Delivery Address Coordinates': coordinates,
      'accepted by' : 'N/A',
      'Order number': orderNo,
      'Item Delivered': productList,
      'Item Total' : total,
      'Service fee': serviceFee,
      'delivery fee': deliveryFee,
      'payment id': paymentID,
      'reward card': rewardCardUrl,
      'receipt':'N/A',
      'Time Stamp': DateTime.now(),
      'complete': 'no',
      'cancelled': 'no'
    };

    FirebaseFirestore.instance.collection('users').doc(userId).collection(
        'Placed Delivery').doc(orderNo).set(private);
  }

  Stream<QuerySnapshot> getRequestedDeliveries() {
    return FirebaseFirestore.instance.collection('All Deliveries').doc(
        'Open Deliveries').collection('Order Info').snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserFistName(String placedUserID){
    return FirebaseFirestore.instance.collection('users').doc(
        placedUserID).snapshots();
  }

  Future<String?> getLatestPlacedDelivery(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('Placed Delivery')
          .orderBy('Time Stamp', descending: true) // Order by 'Time Stamp' in descending order
          .limit(1) // Limit the result to one document (the latest one)
          .get();

      // Check if there are any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Return the latest document
        return querySnapshot.docs.first['Order number'];
      } else {
        // No documents found
        return null;
      }
    } catch (e) {
      // Handle any potential errors
      print('Error retrieving latest placed delivery: $e');
      return null;
    }
  }



  
}