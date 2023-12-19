import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:overlapd/utilities/toast.dart';
import '../screens/home.dart';
import '../utilities/widgets.dart';
import 'delivery_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DeliveryDetails extends StatefulWidget {
  static const id = 'delivery_details_page';
  const DeliveryDetails({super.key});

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  final InputBoxController _itemController = InputBoxController();
  List items = [];
  List Stores = ['Tesco', 'Lidl', 'SuperValu', 'Spar'];
  String? chosenStore;
  final DeliveryService _service = DeliveryService();

  bool canConfirmDelivery() {
    return items.isNotEmpty;
  }

  void _confirmDelivery() async{
    Position currentLocation = await determinePosition();
    await _service.openDelivery(currentLocation, chosenStore!, items, calculateTotalAmount());
    Navigator.of(context).pushReplacement(
        pageAnimationFromTopToBottom(const Home()));
    showToast(text: 'Delivery Confirmed');
  }

  String calculateTotalAmount() {
    num totalQuantity = 0;

    // Calculate the total quantity of items
    for (var item in items) {
      totalQuantity += item['itemQty'];
    }

    // Calculate the total amount based on the quantity and a fixed rate (2.80)
    double totalAmount = totalQuantity * 2.80;

    // Format the total amount as a string
    String formattedTotalAmount = '€${totalAmount.toStringAsFixed(2)}';

    return formattedTotalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  pageAnimationFromTopToBottom(const Home()),
                );
              },
              icon: const Icon(Icons.keyboard_arrow_down_sharp),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Delivery Details',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButtonFormField2<String>(
              decoration: InputDecoration(
                // Add Horizontal padding using menuItemStyleData.padding so it matches
                // the menu padding when button's width is not specified.
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                // Add more decoration..
              ),
              isExpanded: true,
              hint: const Text(
                'Select a store',
                style: TextStyle(fontSize: 20),
              ),
              items: Stores.map((store)
                => DropdownMenuItem<String>(
                  value: store,
                  child: Text(store, style: const TextStyle(fontSize: 20)),
                )
              ).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Please select store';
                }
                return null;
              },
              onChanged: (newValue){
                setState(() {
                  chosenStore = newValue.toString();
                });
              },
              onSaved: (value) {
                chosenStore = value.toString();
              },
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.only(right: 8),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black45,
                ),
                iconSize: 24,
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(flex: 8,child: alphanumericInputBox('Enter Item', true, false, _itemController),),
              const SizedBox(width: 10.0),
              Expanded(flex: 2,child: solidButton(
                  context, 'add',
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
            ),
            const Divider(height: 1),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total: ', style: TextStyle(fontSize: 30)),
                  Text(calculateTotalAmount(), style: const TextStyle(fontSize: 30),)
                ],
              ),
            ),
            solidButton(context, 'Confirm Delivery', _confirmDelivery, canConfirmDelivery())
          ],
        ),
      ),
    );
  }
}
