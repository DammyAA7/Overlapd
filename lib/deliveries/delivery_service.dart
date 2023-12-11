import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class DeliveryService extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();


  Future<void> openDelivery() async {
    final userId = await _auth.getUserId();
    final json = {
      'Delivery Location': 'Dublin',
      'Placed by': userId,
      'Item Delivered': 'Phone',
      'Time Stamp': '13/12/2023'
    };
    FirebaseFirestore.instance.collection('users').doc(userId).collection(
        'Placed Delivery').doc(DateTime.now().toString()).set(json);
    FirebaseFirestore.instance.collection('All Deliveries').doc(
        'Open Deliveries').collection('Order Info').add(json);
  }

  Stream<QuerySnapshot> getRequestedDeliveries() {
    return FirebaseFirestore.instance.collection('All Deliveries').doc(
        'Open Deliveries').collection('Order Info').snapshots();
  }
}