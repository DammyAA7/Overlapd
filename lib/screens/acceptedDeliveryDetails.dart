import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlapd/utilities/toast.dart';
import '../utilities/widgets.dart';
import 'chat/chat.dart';
import 'home.dart';
class AcceptedDeliveryDetails extends StatefulWidget {
  final String placedByUserId;
  final String acceptedByUserName;
  final String? orderID;
  final String? deliveryAddress;
  final List? itemList;
  static const id = 'accepteddeliverydetails_page';
  const AcceptedDeliveryDetails({super.key, required this.placedByUserId, required this.acceptedByUserName, this.orderID, this.deliveryAddress, this.itemList});

  @override
  State<AcceptedDeliveryDetails> createState() => _AcceptedDeliveryDetailsState();
}



class _AcceptedDeliveryDetailsState extends State<AcceptedDeliveryDetails>{
  late List<bool?> isCheckedList;
  late Box<bool?> checkboxStateBox;
  @override
  void initState() {
    super.initState();
    isCheckedList = List.generate(widget.itemList?.length ?? 0, (index) => false);
    initHive();
  }

  Future<void> initHive() async {
    await Hive.openBox<bool>('checkbox_states');
    checkboxStateBox = Hive.box<bool>('checkbox_states');

    // Load checkbox states from Hive
    for (int i = 0; i < isCheckedList.length; i++) {
      isCheckedList[i] = checkboxStateBox.get(i, defaultValue: false);
    }

    setState(() {});
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
                  Navigator.push(
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
            const Spacer(),
            IconButton(onPressed: (){
              Navigator.push(
                context,
                pageAnimationFromBottomToTop(Chat(whatUser: false, receiverUserName: widget.acceptedByUserName, receiverUserId: widget.placedByUserId, orderID: widget.orderID, deliveryAddress: widget.deliveryAddress, itemList: widget.itemList,)),
              );
            }, icon:  const Icon((Icons.chat))),
            const SizedBox(width: 5),
            const Icon((Icons.call)),
          ],
        ),
      ),
      body: Column(
        children: [
          Text('Order No: ${widget.orderID}'),
          Text((widget.deliveryAddress)!),
          const Text('Item List'),

          ElevatedButton(onPressed: (){
            print(widget.itemList);
          }, child: const Text('Order ID')),

          Expanded(
            child: ListView.builder(
              itemCount: widget.itemList?.length ?? 0,
              itemBuilder: (context, index) {
                // Access each item in the list
                final item = widget.itemList![index];
                final itemName = item['itemName'];
                final itemQuantity = item['itemQty'];

                return ListTile(
                  title: CheckboxListTile(
                      value: isCheckedList[index],
                      onChanged: (bool? value) {
                        setState(() {
                          isCheckedList[index] = value;
                          // Save checkbox state to Hive
                          checkboxStateBox.put(index, value);
                        });

                      },
                      title: Text('$itemName - $itemQuantity')),
                  // Add more details or customize the ListTile as needed
                );
              },
            ),
          ),
          solidButton(context, 'Upload Receipt', _captureReceipt, true)
        ],
      ),
    );
  }
  void _captureReceipt() async{
    ImagePicker imagePicker = ImagePicker();
    XFile? receipt = await imagePicker.pickImage(source: ImageSource.camera);
    if( receipt== null) return;
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Receipts');
    Reference referenceImageToUpload = referenceDirImages.child((widget.orderID)!);
    try{
      await referenceImageToUpload.putFile(File(receipt.path));
      String downloadURL = await referenceImageToUpload.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('All Deliveries')
          .doc('Open Deliveries')
          .collection('Order Info')
          .doc(widget.orderID)
          .update({'receipt': downloadURL});
      showToast(text: "Successfully uploaded receipt");
    }catch(e){
      showToast(text: "Error uploading Image");
    }

  }
}
