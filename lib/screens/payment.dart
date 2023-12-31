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
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title:  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              // Navigate to the home page with a fade transition
              Navigator.pushReplacement(
                context,
                pageAnimationlr(const Home()),
              );
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Payment',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ],
      ),
    );
  }
}
