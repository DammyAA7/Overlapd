import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class DeliveryService extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();


  Future<void> openDelivery() async {
    final userId = await _auth.getUserId();
    var orderNo;
    final public = {
      'Delivery Location': 'Dublin',
      'Placed by': userId,
      'Item Delivered': 'Phone',
      'Time Stamp': '13/12/2023',
      'complete': 'no',
      'cancelled': 'no'
    };
    final orderInfoDocRef = await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .add(public);
    orderNo = orderInfoDocRef.id;
    print(orderNo);
    final private = {
      'Delivery Location': 'Dublin',
      'Order number': orderNo,
      'Item Delivered': 'Phone',
      'Time Stamp': '13/12/2023',
      'complete': 'no',
      'cancelled': 'no'
    };

    FirebaseFirestore.instance.collection('users').doc(userId).collection(
        'Placed Delivery').doc(DateTime.now().toString()).set(private);
  }

  Stream<QuerySnapshot> getRequestedDeliveries() {
    return FirebaseFirestore.instance.collection('All Deliveries').doc(
        'Open Deliveries').collection('Order Info').snapshots();
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