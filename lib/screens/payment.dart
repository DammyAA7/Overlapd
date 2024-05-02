

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';
import 'home.dart';


class Payment extends StatefulWidget {
  static const id = 'payment_page';
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}


class _PaymentState extends State<Payment> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  late Future<List<DocumentSnapshot>> transfers;
  int available = 0;
  int pending = 0;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    getCurrentStripeBalance();
    transfers = getTransfers();
  }
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
              pageAnimationlr(const Home()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title:  Text(
          'Payment Methods',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF21D19F).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('Balance'),
                Row(
                  children: [
                    Text('Available: €${(available / 100).toStringAsFixed(2)}'),
                    const Spacer(),
                    Text('Pending: €${(pending / 100).toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            indicatorColor: Colors.black,
                            labelColor: Colors.black,
                            tabs: [
                              Tab(child: Text('Transfers')),
                              Tab(child: Text('Payouts')),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                FutureBuilder<List<DocumentSnapshot>>(
                                  future: transfers,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Center(child: Text('Error loading data'));
                                    } else {
                                      return ListView.builder(
                                        itemCount: snapshot.data?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          final data = snapshot.data![index];
                                          // Build your UI using data
                                          return ListTile(
                                            title: Text(data['amount']),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                                Text('Payouts Content'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: solidButton(context, 'Add Payment Card', () async{
        }, true),
      ),
    );
  }

  void getCurrentStripeBalance() async{
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_UID)
        .get();
    try{
      final response = await http.post(
          Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeAccountBalance'),
          body: {
            'destination':userSnapshot['Stripe Account Id']
          });
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        available = jsonResponse['available'][0]['amount'];
        pending = jsonResponse['pending'][0]['amount'];
      });
    } catch(e) {
      print(e);
    }
  }

  Future<List<DocumentSnapshot>> getTransfers() async {
    // Fetch and return data from Firestore for transfers
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('stripe users')
        .doc('acct_1PAELVINS2WBNnto')
        .collection('transfers')
        .get();
    return querySnapshot.docs;
  }

}
