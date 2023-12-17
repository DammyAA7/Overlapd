import 'package:flutter/material.dart';

import '../screens/home.dart';
import '../utilities/widgets.dart';

class DeliveryDetails extends StatefulWidget {
  static const id = 'delivery_details_page';
  const DeliveryDetails({super.key});

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  final InputBoxController _itemController = InputBoxController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(flex: 7,child: letterInputBox('Enter Item', true, false, _itemController),),
              SizedBox(width: 10.0),
              Expanded(flex: 3,child: solidButton(context, 'Add Item', () {}, true),),
            ],),
          ],
        ),
      ),
    );
  }
}
