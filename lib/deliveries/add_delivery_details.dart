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
  List items = [];

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
              Expanded(flex: 7,child: alphanumericInputBox('Enter Item', true, false, _itemController),),
              const SizedBox(width: 10.0),
              Expanded(flex: 3,child: solidButton(
                  context, 'Add Item',
                      () {
                    // Check if item controller is not empty
                    if (_itemController.getText().isNotEmpty) {
                      setState(() {
                        items.add({
                          'itemName': _itemController.getText(),
                          'itemQty': 1,
                        });
                        // Clear the text in the input box
                        _itemController.clear();
                      });
                    }
                  },
                  true)
              ),
            ],),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index){
                  return itemTile(items[index]['itemName'], items[index]['itemQty'], () {
                    setState(() {
                      items[index]['itemQty'] += 1;
                    });
                  }, () {
                    setState(() {
                      if (items[index]['itemQty'] > 1) {
                        items[index]['itemQty'] -= 1;
                      } else{
                        items.remove(items[index]);
                      }
                    });
                  },);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
