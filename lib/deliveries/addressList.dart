import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/deliveries/addDeliveryAddress.dart';

import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key});

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Navigate to the home page with a fade transition
            Navigator.pop(context,);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title:  Text(
          'Addresses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: hasAddressStored(),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: solidButton(context, 'Add Address', () {
          Navigator.push(
            context,
            pageAnimationrl(const AddDeliveryAddress()),
          );
        }, true),
      ),
    );
  }

  Widget hasAddressStored() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_UID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Text('No Addresses Stored');
        } else {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> addressBook = data['Address Book'];
          if (data.containsKey('Address Book') && data['Address Book'] is List && addressBook.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: addressBook.length,
              itemBuilder: (context, index) {
                final address = addressBook[index] as Map<String, dynamic>;
                return ListTile(
                  title: Text(address['Full Address'] ?? 'No address'),
                  subtitle: Text('House Number: ${address['House Number'] ?? 'N/A'}'),
                  // Add more fields as necessary
                );
              },
            );
          } else {
            return const Text('No Addresses Stored');
          }
        }
      },
    );
  }
}
