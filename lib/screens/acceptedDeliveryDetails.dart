import 'package:flutter/material.dart';

import '../utilities/widgets.dart';
import 'home.dart';
class AcceptedDeliveryDetails extends StatefulWidget {
  static const id = 'accepteddeliverydetails_page';
  const AcceptedDeliveryDetails({super.key});

  @override
  State<AcceptedDeliveryDetails> createState() => _AcceptedDeliveryDetailsState();
}

class _AcceptedDeliveryDetailsState extends State<AcceptedDeliveryDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                  'Active Delivery',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ],),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Icon((Icons.chat)),
              SizedBox(width: 15),
              Icon((Icons.call)),
            ],)
          ],
        ),
      ),
    );
  }
}
