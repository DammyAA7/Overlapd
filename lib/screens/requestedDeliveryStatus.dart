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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRewardCard();
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
              child: solidButton(context, 'Upload Receipt', () => _captureRewardCard(), true),
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

  Future<void> fetchRewardCard() async {
    // Get the document from Firestore
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .doc(widget.orderId)
        .get();

    Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;

    // Extract the reward card URL from the document, safely handling the case where data is null
    String? rewardCardUrl = data?['reward card'];

    // Check if the URL is not null
    if (rewardCardUrl != null) {
      // Update the state with the fetched reward card URL
      setState(() {
        this.rewardCardUrl = rewardCardUrl;
      });
    }
  }

  void _captureRewardCard() async{
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
          .update({'receipt': downloadURL, 'status' : 'Shopping Complete', 'complete' : true});
      showToast(text: "Successfully uploaded receipt");
    }catch(e){
      showToast(text: "Error uploading Image");
    }

  }

}



