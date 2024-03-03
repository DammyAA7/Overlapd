import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/pickers/picker.dart';

import '../deliveries/delivery_service.dart';
import '../utilities/widgets.dart';

class Orders extends StatefulWidget {
  final String store;
  const Orders({super.key, required this.store});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final DeliveryService _service = DeliveryService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Navigate to the home page with a fade transition
            Navigator.pushReplacement(
              context,
              pageAnimationlr(const Picker()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title:  Text(
          '${widget.store} Orders',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: _buildList(),
    );
  }

  Widget _buildList(){
    return StreamBuilder(
        stream: _service.getRequestedDeliveries(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the data is still loading, return a loading indicator
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            // If there is no data or the data is empty, display a message
            return const Text('No Orders available');
          } else {

            var storeOrders = snapshot.data!.docs.where((doc) => doc['Grocery Store'] == widget.store).toList();

            if (storeOrders.isEmpty) {
              // If there are no orders for the store, display a message
              return const Center(child: Text('No Orders available for this store'));
            }

            return ListView(
              children: snapshot.data!.docs.map((document) {
                return _buildItem(document);
              }).toList(),
            );
          }
        });
  }

  Widget _buildItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    int numberOfItems = data['Items for Delivery'] != null ? (data['Items for Delivery'] as List).length : 0;
    return data['Grocery Store'] == widget.store ? Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: const Color(0xFF21D19F).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20)
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: ${data['Item Total']}'),
                Text('Number of Items: $numberOfItems '),

              ],
            ),
          ),
        ),
      ),
    ) : const SizedBox.shrink();
  }
}
