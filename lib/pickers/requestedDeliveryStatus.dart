import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utilities/toast.dart';
import '../utilities/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class RequestedDeliveryStatus extends StatefulWidget {
  static const id = 'requesteddeliverystatus_page';
  final String orderId;
  const RequestedDeliveryStatus({super.key, required this.orderId});

  @override
  State<RequestedDeliveryStatus> createState() => _RequestedDeliveryStatusState();
}

class _RequestedDeliveryStatusState extends State<RequestedDeliveryStatus> {
  String? rewardCardUrl;
  double totalPaid = 0.0;
  double totalShopped = 0.0;
  final InputBoxController total = InputBoxController();
  List<dynamic> itemsForDelivery = [];
  bool isReceiptAvailable = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchOrderDetails();
  }
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
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Delivery Status',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ],),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    //Navigator.pushReplacement(context,pageAnimationFromBottomToTop(Chat(whatUser: true, receiverUserId: widget.acceptedByUserId, receiverUserName: widget.placedByUserName,)),);
                  },
                    child: const Icon((Icons.chat))),
                const SizedBox(width: 15),
                const Icon((Icons.call)),
              ],)
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            InkWell(
              onTap: () => rewardCardUrl == null ? showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Reward Card Unavailable'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ) : _viewRewardCard(rewardCardUrl!),
              child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: 5,
                  leading: const Icon(
                      Icons.card_membership_outlined,
                      color: Colors.black
                  ),
                  title: Text(
                    rewardCardUrl == null ? 'Reward Card unavailable' : 'View Reward Card',
                    style: Theme.of(context).textTheme.titleLarge,)
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: solidButton(context, 'Upload Receipt', () => _captureReceipt(), true),
            ),
            Row(
              children: [
                Expanded(flex: 2, child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: numberInputBox('Enter Total', true, false, total),
                )),
                Expanded(flex: 3, child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: solidButton(context, 'Capture Payment', (){
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: const Text('Capture Final Amount'),
                        content: Text('€${total.getText()} paid at checkout?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => captureAmount(),
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('No'),
                          )
                        ],
                      ),
                    );
                  }, isReceiptAvailable),
                )
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Total Paid: €$totalPaid'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Total Shopped: €${totalShopped.toStringAsFixed(2)}'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: itemsForDelivery.length,
                itemBuilder: (context, index) {
                  var item = itemsForDelivery[index];
                  return ListTile(
                    leading: Image.network(item['product']['imageUrl'], width: 50, height: 50),
                    title: Text(item['product']['title']),
                    subtitle: Text('Quantity: ${item['quantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: item['found'] ?? false,
                          onChanged: (bool? value) {
                            // Ensure only one checkbox is selected at a time
                            if(value!){
                              setState(() {
                                itemsForDelivery[index]['found'] = value;
                                itemsForDelivery[index]['unavailable'] = !value!;
                                totalShopped += (item['product']['price'] * item['quantity']);
                              });
                            }

                          },
                        ),
                        Checkbox(
                          value: item['unavailable'] ?? false,
                          onChanged: (bool? value) {
                            // Ensure only one checkbox is selected at a time
                            if(value!){
                              setState(() {
                                itemsForDelivery[index]['unavailable'] = value;
                                itemsForDelivery[index]['found'] = !value!;
                                totalShopped != 0 ? totalShopped -= (item['product']['price'] * item['quantity']) : totalShopped;
                                // Adjust the totalShopped accordingly if necessary
                                // This part might require adjustments based on your app's logic
                              });
                            }

                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        )
      ),
    );
  }

  void _viewRewardCard(String rewardCardUrl) {
    // Show the reward card with options to "OK" or "Retake"
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reward Card'),
          content: Image.network(rewardCardUrl),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _captureReceipt() async{
    ImagePicker imagePicker = ImagePicker();
    XFile? receipt = await imagePicker.pickImage(source: ImageSource.camera);
    if( receipt== null) return;
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Receipts');
    Reference referenceImageToUpload = referenceDirImages.child(widget.orderId);
    try{
      await referenceImageToUpload.putFile(File(receipt.path));
      String downloadURL = await referenceImageToUpload.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('All Deliveries')
          .doc('Open Deliveries')
          .collection('Order Info')
          .doc(widget.orderId)
          .update({'receipt': downloadURL});
      setState(() {
        isReceiptAvailable = true;
      });
      showToast(text: "Successfully uploaded receipt");
    }catch(e){
      showToast(text: "Error uploading Image");
    }

  }

  void captureAmount() async {
    // Create a map with the data you want to submit
    DocumentSnapshot orderDocument = await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .doc(widget.orderId)
        .get();

    // Check if the document exists and has data
    if (orderDocument.exists && orderDocument.data() != null) {
      final data = orderDocument.data() as Map<String, dynamic>;

      // Extract fields from the document
      String paymentIntentId = data['payment id'];// Assuming field name is 'paymentIntentId'

      double itemTotal = double.parse(total.getText());

      String deliveryFeesWithEuro = data['delivery fee'];
      // Removing the euro sign and converting to double
      double deliveryFees = double.parse(deliveryFeesWithEuro.replaceAll('€', ''));

      double serviceFees = double.parse((double.parse(total.getText()) * 0.11).toStringAsFixed(2));
      // Calculate the total amount
      double totalAmount = itemTotal + deliveryFees + serviceFees;
      print((totalAmount * 100).round());
      try{
        int amountToCapture = (totalAmount * 100).round();
        final response = await http.post(Uri.parse(
            'https://us-central1-overlapd-13268.cloudfunctions.net/StripeCapturePaymentIntent'),
            body: {
              'id': paymentIntentId,
              'amount_to_capture': amountToCapture.toString(),
            });
        final jsonResponse = jsonDecode(response.body);
        await FirebaseFirestore.instance
            .collection('All Deliveries')
            .doc('Open Deliveries')
            .collection('Order Info')
            .doc(widget.orderId)
            .update({'status' : 'Shopping Complete',
                      'complete' : true,
                      'charge id' : jsonResponse['latest_charge']
            });
      } catch(e){
        print(e);
      }
    }

    Map<String, dynamic> captureInfo = {
      'Item Total': '€${total.getText()}',
      'Service fee': '€${(double.parse(total.getText()) * 0.11).toStringAsFixed(2)}',
    };
    await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .doc(widget.orderId)
        .update(captureInfo);

    // Show a success message
    showToast(text: 'Amount Captured');
    // Optionally clear the fields if the submission was successful
    setState(() {
      total.clear();
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> fetchOrderDetails() async {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .doc(widget.orderId)
        .get();

    if (orderSnapshot.exists) {
      Map<String, dynamic> data = orderSnapshot.data() as Map<String, dynamic>;
      setState(() {
        rewardCardUrl = data['reward card'];
        totalPaid = double.tryParse(data['Item Total'].replaceAll('€', '')) ?? 0.0;
        itemsForDelivery = data['Items for Delivery'];
        // Initialize totalShopped with 0.0 or calculate if needed
      });
    }
  }

}



