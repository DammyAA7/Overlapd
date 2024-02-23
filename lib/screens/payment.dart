

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utilities/widgets.dart';
import 'home.dart';


class Payment extends StatefulWidget {
  static const id = 'payment_page';
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}


class _PaymentState extends State<Payment> {
  int available = 0;
  int pending = 0;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    getCurrentStripeBalance();
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
          height: 100,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color(0xFF21D19F).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Balance'),
                Row(
                  children: [
                    Text('Available: €${(available / 100).toStringAsFixed(2)}'),
                    Spacer(),
                    Text('Pending: €${(pending / 100).toStringAsFixed(2)}'),
                  ],
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
    try{
      final response = await http.post(
          Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeAccountBalance'),
      );
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        available = jsonResponse['available'][0]['amount'];
        pending = jsonResponse['pending'][0]['amount'];
      });
    } catch(e) {
      print(e);
    }
  }

}
