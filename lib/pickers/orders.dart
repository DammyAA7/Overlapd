import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/pickers/picker.dart';
import 'package:overlapd/utilities/toast.dart';

import '../services/deliveryService/delivery_service.dart';
import 'requestedDeliveryStatus.dart';
import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';

class Orders extends StatefulWidget {
  final String store;
  const Orders({super.key, required this.store});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  late final TextEditingController inputController;
  final DeliveryService _service = DeliveryService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();

  @override
  void initState() {
    super.initState();
    inputController =
        TextEditingController(); // Initialize the TextEditingController
  }

  @override
  void dispose() {
    inputController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          title: Text(
            '${widget.store} Orders',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 4.0,
                    indicator: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelColor: Colors.white,
                    tabs: const [
                      Tab(
                          child: Text('Order requests',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      Tab(
                          child: Text('Shopping Complete',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                      Tab(
                          child: Text('Ready for pickup',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                    ]),
              ),
            ),
            Expanded(
              flex: 10,
              child: TabBarView(children: [
                _buildList('Order Requested',
                    'Shopping in progress'), // Orders in Request or Shopping in progress
                _buildList(
                    'Shopping Complete', null), // Orders ready for pickup
                _buildList('Pick up assigned',
                    'Delivery Complete'), // Completed orders
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildList(String status1, String? status2) {
    return StreamBuilder(
        stream: _service.getRequestedDeliveries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return const Text('No Orders available');
          } else {
            // Filter orders based on status
            var filteredOrders = snapshot.data!.docs.where((doc) {
              return doc['Grocery Store'] == widget.store &&
                  (doc['status'] == status1 ||
                      (status2 != null && doc['status'] == status2));
            }).toList();

            if (filteredOrders.isEmpty) {
              return const Center(
                  child: Text('No Orders available for this category'));
            }

            return ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = filteredOrders[index];
                bool hasIncompleteOrders = snapshot.data!.docs.any((doc) =>
                    doc['accepted by'] == _UID && doc['complete'] != true);
                if (status1 == 'Order Requested' ||
                    (status2 != null && 'Shopping in progress' == status2)) {
                  return _buildItemTab1(document, hasIncompleteOrders);
                } else if (status1 == 'Shopping Complete') {
                  return _buildItemTab2(document, hasIncompleteOrders);
                } else if (status1 == 'Pick up assigned' ||
                    (status2 != null && 'Delivery Complete' == status2)) {
                  return _buildItemTab3(document, hasIncompleteOrders);
                }
                return const Center(
                    child: Text('No Orders available for this category'));
              },
            );
          }
        });
  }

  Widget _buildItemTab1(DocumentSnapshot document, bool hasIncompleteOrders) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String docId = document.id; // Get the document ID
    int numberOfItems = data['Items for Delivery'] != null
        ? (data['Items for Delivery'] as List).length
        : 0;
    return data['Grocery Store'] == widget.store
        ? InkWell(
            onTap: () {
              if (data['accepted by'] == _UID) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RequestedDeliveryStatus(orderId: docId)));
              } else {
                if (hasIncompleteOrders) {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) => AlertDialog(
                      title: const Text('Incomplete Order'),
                      content: const Text(
                          'You have an incomplete order. Please complete it before accepting new orders.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                            title: const Text('Start shopping for'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop('No'),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(dialogContext).pop('Yes');
                                  await FirebaseFirestore.instance
                                      .collection('All Deliveries')
                                      .doc('Open Deliveries')
                                      .collection('Order Info')
                                      .doc(docId)
                                      .update({
                                    'status': 'Shopping in progress',
                                    'accepted by': _UID,
                                    'orderHandedOver': false
                                  });

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RequestedDeliveryStatus(
                                                  orderId: docId)));
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ));
                }
              }
            },
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: const Color(0xFF21D19F).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total: ${data['Item Total']}'),
                        Text('Number of Items: $numberOfItems'),
                        Text('Status: ${data['status']}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildItemTab2(DocumentSnapshot document, bool hasIncompleteOrders) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String docId = document.id; // Get the document ID
    int numberOfItems = data['Items for Delivery'] != null
        ? (data['Items for Delivery'] as List).length
        : 0;
    return data['Grocery Store'] == widget.store
        ? Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFF21D19F).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20)),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: ${data['Item Total']}'),
                      Text('Number of Items: $numberOfItems'),
                      Text('Status: ${data['status']}'),
                    ],
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildItemTab3(DocumentSnapshot document, bool hasIncompleteOrders) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String docId = document.id; // Get the document ID
    return data['Grocery Store'] == widget.store
        ? InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  title: const Text('Confirm the 2 digit code from deliverer'),
                  content: TextField(
                    controller: inputController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: "Enter the code here"),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        if (inputController.text ==
                            data['picker code'].toString()) {
                          showToast(text: 'Code Confirmed');
                          inputController.clear();
                          await FirebaseFirestore.instance
                              .collection('All Deliveries')
                              .doc('Open Deliveries')
                              .collection('Order Info')
                              .doc(docId)
                              .update({
                            'deliverer code': Random().nextInt(90) + 10,
                            'status': 'Order Handed Over',
                            'orderHandedOver': true
                          });
                          Navigator.of(dialogContext).pop();
                        } else {
                          showToast(text: 'Wrong Code');
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: const Color(0xFF21D19F).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Id: $docId'),
                        Text('Status: ${data['status']}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
