import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:overlapd/deliveries/addressList.dart';
import 'package:provider/provider.dart';
import '../deliveries/delivery_service.dart';
import '../screens/home.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/toast.dart';
import '../utilities/widgets.dart';
import 'groceryRange.dart';
import 'dart:io';


class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  TextEditingController searchText = TextEditingController();
  final DeliveryService _service = DeliveryService();
  String predictions = '';
  String? fullAddress;
  String? addressCoordinates;
  Position? currentLocation;
  bool deliveryTime = true;
  bool shoppingPreference = true;
  int scheduleDelivery = -1; // -1 indicates no checkbox is initially selected
  int number = 0;
  List scheduleDeliveryTimes = [];
  String chosenScheduleDeliveryTime = '';
  String? houseNumber;
  String? streetAddress;
  String? locality;
  String? county;
  String? postalCode;
  String? rewardCardUrl;
  final InputBoxController _itemController = InputBoxController();
  var now = DateTime.now();
  late Box<String?> savedAddress;


  void updateChosenScheduleDeliveryTime(String newTime) {
    setState(() {
      chosenScheduleDeliveryTime = newTime;
    });
  }
  void filterScheduleDeliveryTimes() {
    List<String> newScheduleDeliveryTimes = [];
    if (now.isAfter(DateTime(now.year, now.month, now.day, 17, 0, 0)) && now.isBefore(DateTime(now.year, now.month, now.day, 23, 59, 59))
    || now.isAfter(DateTime(now.year, now.month, now.day, 0, 0, 0)) && now.isBefore(DateTime(now.year, now.month, now.day, 7, 59, 59))
    ){
      newScheduleDeliveryTimes = [
        'Slot (8am - 12pm)',
        'Slot (12pm - 4pm)',
        'Slot (4pm - 8pm)',
      ];
    }
    else if(now.isAfter(DateTime(now.year, now.month, now.day, 16, 0, 0))){
      now.hour -  7< 10 ? newScheduleDeliveryTimes.add('Slot (${now.hour - 11}pm - ${now.hour - 7}pm)') : null;
    } else if(now.isAfter(DateTime(now.year, now.month, now.day, 12, 0, 0))){
      newScheduleDeliveryTimes = [
        'Slot (${now.hour - 11}pm - ${now.hour - 7}pm)',
      ];
      now.hour - 3 < 10 ? newScheduleDeliveryTimes.add('Slot (${now.hour - 7}pm - ${now.hour - 3}pm)') : null;
    }
    else if(now.isAfter(DateTime(now.year, now.month, now.day, 8, 0, 0))){
      newScheduleDeliveryTimes = [
        'Slot (${now.hour  + 1}${now.hour  + 1 == 12 ? 'pm' : 'am'} - ${now.hour  - 7}pm)',
        'Slot (${now.hour - 7}pm - ${now.hour - 3}pm)',
      ];
      now.hour + 1 < 10 ? newScheduleDeliveryTimes.add('Slot (${now.hour - 3}pm - ${now.hour + 1}pm)') : null;
    }
    setState(() {
      scheduleDeliveryTimes = newScheduleDeliveryTimes;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadLastSelectedOrDefaultAddress();
    fetchRewardCard();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                // Navigate to the home page with a fade transition
                Navigator.pop(
                    context);
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            title:  Text(
              'Checkout',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deliver to',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () async{
                    await Navigator.push(
                        context,
                      pageAnimationrl(const AddressList()),
                    );
                    setState(() {
                      loadLastSelectedOrDefaultAddress();
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: fullAddress == null
                      ? const Text('Set Delivery Location')
                      : Text(fullAddress!, overflow: TextOverflow.clip, maxLines: 1,),
                ),
                const Divider(thickness: 1),
                Text(
                  'Delivery date & time',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        child: Container(
                          width: 150,
                          height: 70,
                          decoration: BoxDecoration(
                              color: deliveryTime ? const Color(0xFF6EE8C5) : Colors.grey,
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: Center(
                              child: Text(
                                'Asap',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                          ),
                        ),
                        onTap: (){
                          setState(() {
                            if(!deliveryTime){
                              deliveryTime = !deliveryTime;
                            }
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          width: 150,
                          height: 70,
                          decoration: BoxDecoration(
                            color: !deliveryTime ? const Color(0xFF6EE8C5) : Colors.grey,
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: Center(
                              child: Text(
                                'Schedule time',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            if(deliveryTime){
                              deliveryTime = !deliveryTime;
                            }
                          });
                          filterScheduleDeliveryTimes();
                          await showDeliverySlots();
                        },
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 5,
                    leading: Icon(
                        Icons.access_time_outlined,
                        color: deliveryTime ? Colors.grey : Colors.black
                    ),
                    title: Text(
                        deliveryTime ? 'Now' : chosenScheduleDeliveryTime == '' ? 'Choose time' : chosenScheduleDeliveryTime,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: deliveryTime ? Colors.grey : Colors.black
                      ),
                    ),
                  ),
                  onTap: () async {
                    now = DateTime.now();
                    if(!deliveryTime){
                      filterScheduleDeliveryTimes();
                      await showDeliverySlots();
                    }
                  },
                ),
                now.hour + 1 > 20 || now.hour + 1 < 8? const Text('All stores are currently closed') : const SizedBox.shrink(),
                const Divider(thickness: 1),
                GestureDetector(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 5,
                    leading: const Icon(
                        Icons.shopping_basket_outlined,
                        color: Colors.black
                    ),
                    title: Text(
                      'Shopping preferences',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  onTap: () async {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context){
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState){
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      IntrinsicHeight(
                                        child: Column(
                                        children: [
                                          Flexible(
                                            child: CheckboxListTile(
                                              title: Text("Picker has full discretion over substitutable items", style: Theme.of(context).textTheme.titleLarge,),
                                              value: shoppingPreference,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  shoppingPreference = !shoppingPreference;
                                                });
                                              },
                                            ),
                                          ),
                                          Flexible(
                                            child: CheckboxListTile(
                                              title: Text("Picker will contact you to get your approval", style: Theme.of(context).textTheme.titleLarge,),
                                              value: !shoppingPreference,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  shoppingPreference = !shoppingPreference;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }

                    );
                  },
                ),
                GestureDetector(
                  onTap: () => rewardCardUrl == null ? _captureRewardCard : _viewOrRetakeRewardCard,
                  child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      horizontalTitleGap: 5,
                    leading: const Icon(
                        Icons.card_membership_outlined,
                        color: Colors.black
                    ),
                    title: Text(
                      rewardCardUrl == null ? 'Upload Reward Card' : 'View Reward Card',
                      style: Theme.of(context).textTheme.titleLarge,)
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text(value.calculateTotalAmount())
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery fees:'),
                          deliveryTime ? const Text('€6.99') : const Text('€5.99')
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Service fees:'),
                          Text('€${value.calculateServiceFees().toStringAsFixed(2)}')
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:'),
                          Text(value.totalAmountPlusFees(deliveryTime)[0])
                        ],
                      ),
                      solidButton(context, 'Checkout', () async{
                        await initPayment((double.parse(value.stripEuroSign(value.calculateTotalAmount())) * 100).toInt().toString(), _auth.getUsername(), context, value);
                      }, (chosenScheduleDeliveryTime != '' && fullAddress != null) || (deliveryTime && fullAddress != null) ? true : false),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Future<void> initPayment(String amount, String email, BuildContext context, Cart value) async{
    try{
      final response = await http.post(Uri.parse(
          'https://us-central1-overlapd-13268.cloudfunctions.net/StripePaymentIntent'),
        body: {
          'amount': amount,
          'email': email,
          'deliveryFee': deliveryTime ? '699' : '599'
        });

      final jsonResponse = jsonDecode(response.body);
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            customerId:  jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
            merchantDisplayName: 'Overlap Delivery',
            billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(attachDefaultsToPaymentMethod: true, address: AddressCollectionMode.full, name: CollectionMode.always)
          )
      );
      await Stripe.instance.presentPaymentSheet();
      List<String> feeBreakdown = value.totalAmountPlusFees(deliveryTime);
      _checkout('Tesco', value.cart, feeBreakdown[3], feeBreakdown[1], feeBreakdown[2], jsonResponse['id']);
    } catch(e){
      print(e);
    }
  }

  void _checkout(String chosenStore, Map<Product, int> products, String amount, String serviceFee, String deliveryFees, String paymentID) async{
    List<Map<String, dynamic>> productListMap = context.read<Cart>().toMapList();
    await _service.openDelivery(fullAddress!, '53.27246467559411, -6.3283508451421655', chosenStore, productListMap, amount, paymentID, rewardCardUrl, serviceFee, deliveryFees);
    context.read<Cart>().clearCart();
    Navigator.of(context).pushReplacement(
        pageAnimationFromTopToBottom(const Home()));
    showToast(text: 'Order Confirmed');
  }



  Future showDeliverySlots(){
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState){
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      now.isAfter(DateTime(now.year, now.month, now.day, 17, 0, 0)) ? const Text('Scheduled Deliveries available tomorrow') : const SizedBox.shrink(),
                      Expanded(
                        child: ListView.builder(
                            itemCount: scheduleDeliveryTimes.length,
                            itemBuilder: (BuildContext context, int index){
                              return CheckboxListTile(
                                title: Text(scheduleDeliveryTimes[index], style: Theme.of(context).textTheme.bodyMedium,),
                                value: scheduleDelivery == index,
                                onChanged: (bool? value) {
                                  if (value == true) {
                                    setState(() {
                                      scheduleDelivery = index;
                                      updateChosenScheduleDeliveryTime(scheduleDeliveryTimes[index]);
                                    });
                                  }
                                },
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

    );
  }

  Future<void> loadLastSelectedOrDefaultAddress() async {
    final userDocSnapshot = await _auth.getAccountInfoGet(_UID); // Assuming this returns a Future<DocumentSnapshot>
    Map<String, dynamic>? userData = userDocSnapshot.data();
    if (userData != null) {
      if (userData.containsKey('lastAddressSelected') && userData['lastAddressSelected'] != null) {
        // Last selected address exists, use it
        setState(() {
          fullAddress = userData['lastAddressSelected']['Full Address'];
          addressCoordinates = '${userData['lastAddressSelected']['Coordinates']['lat']}, ${userData['lastAddressSelected']['Coordinates']['lng']}';
          print("coordinates $addressCoordinates");
        });
      } else if (userData.containsKey('Address Book') && userData['Address Book'].isNotEmpty) {
        // Check for a default address in the address book
        final defaultAddress = (userData['Address Book'] as List).cast<Map<String, dynamic>?>().firstWhere(
              (address) => address != null && address['Default'] == true,
          orElse: () => null,
        );

        if (defaultAddress != null) {
          // Default address exists, use it
          setState(() {
            fullAddress = defaultAddress['Full Address'];
            addressCoordinates = '${defaultAddress['Coordinates']['lat']}, ${userData['Address Book']['Coordinates']['lng']}';
          });
        }
      }
    }
  }

  Future<void> fetchRewardCard() async {
    // Fetch the reward card URL from Firestore
    final userDoc = await _auth.getAccountInfoGet(_UID);
    setState(() {
      rewardCardUrl = userDoc.data()?['reward card'];
    });
  }

  void _viewOrRetakeRewardCard() {
    // Show the reward card with options to "OK" or "Retake"
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reward Card'),
          content: Image.network(rewardCardUrl!),
          actions: <Widget>[
            TextButton(
              child: Text('Retake'),
              onPressed: () {
                Navigator.of(context).pop();
                _captureRewardCard(); // Retake the reward card
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _captureRewardCard() async{
    ImagePicker imagePicker = ImagePicker();
    XFile? reward = await imagePicker.pickImage(source: ImageSource.camera);
    if(reward == null) return;
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Reward_Cards');
    Reference referenceImageToUpload = referenceDirImages.child(_UID);

    try{
      await referenceImageToUpload.putFile(File(reward.path));
      String downloadURL = await referenceImageToUpload.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_UID)
          .update({'reward card': downloadURL});
      showToast(text: "Successfully uploaded receipt");
    }catch(e){
      showToast(text: "Error uploading Image");
    }

  }

}
