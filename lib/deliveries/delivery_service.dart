import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class DeliveryService extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();


  Future<void> openDelivery(Position currentLocation, String storeName, List itemList, String total) async {
    final userId = await _auth.getUserId();
    String orderNo;


    final geoPoint = GeoPoint(currentLocation.latitude, currentLocation.longitude);

    final public = {
      'Delivery Destination': geoPoint,
      'Grocery Store': storeName,
      'Placed by': userId,
      'Items for Delivery': itemList,
      'Item Total' : total,
      'Time Stamp': DateTime.now(),
      'accepted by' : 'N/A',
      'complete': 'no',
      'cancelled': 'no',
      'declined By': ''
    };
    final orderInfoDocRef = await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .add(public);
    orderNo = orderInfoDocRef.id;
    final private = {
      'Grocery Store': storeName,
      'accepted by' : 'N/A',
      'Order number': orderNo,
      'Item Delivered': itemList,
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