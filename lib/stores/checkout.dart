
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../deliveries/delivery_service.dart';
import '../screens/home.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/deliveryDetailsUtilities.dart';
import '../utilities/networkUtilities.dart';
import '../utilities/toast.dart';
import '../utilities/widgets.dart';
import 'groceryRange.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final DeliveryService _service = DeliveryService();
  String? setAddress;
  Position? currentLocation;
  bool deliveryTime = true;
  int scheduleDelivery = -1; // -1 indicates no checkbox is initially selected
  List scheduleDeliveryTimes = [];
  String chosenScheduleDeliveryTime = '';
  var now = DateTime.now();
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
    super.initState();
    filterScheduleDeliveryTimes();
    print(DateTime.now());
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Scaffold(
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
                  onPressed: (){
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context){
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.add_location_alt_outlined),
                                      const SizedBox(width: 5),
                                      const Text('Set Delivery Location'),
                                      const Spacer(),
                                      IconButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          icon: const Icon(Icons.arrow_drop_down_outlined, size: 35,)),
                                    ],
                                  ),
                                  Form(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          onChanged: (value){
                                            placeAutoComplete(value);
                                          },
                                          textInputAction: TextInputAction.search,
                                          decoration: const InputDecoration(
                                              hintText: "Search your location",
                                              prefixIcon: Icon(Icons.search)
                                          ),
                                        ),
                                      )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: ()  async{
                                        currentLocation = await determinePosition();
                                        String? formattedAddress = await getAddressFromCoordinates(currentLocation!.latitude, currentLocation!.longitude);
                                        setState(() {
                                          setAddress = formattedAddress;
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      icon: const Icon(Icons.my_location_rounded),
                                      label: const Text('Use my Current Location'),
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          fixedSize: Size(MediaQuery.of(context).size.width, 50),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10))
                                          )
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount: placePredictions.length,
                                        itemBuilder: (context,index) => locationListTile(placePredictions[index].description!, () {
                                          setState(() {
                                            setAddress = placePredictions[index].description;
                                            getCoordinates(setAddress!);
                                            Navigator.of(context).pop();
                                          });
                                        })
                                    ),
                                  )

                                ],
                              ),
                            ),
                          );
                        }
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: setAddress == null
                      ? const Text('Set Delivery Location')
                      : Text(setAddress!, overflow: TextOverflow.clip, maxLines: 1,),
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
                        onTap: (){
                          setState(() {
                            if(deliveryTime){
                              deliveryTime = !deliveryTime;
                            }
                          });
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context){
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.8,
                                  width: MediaQuery.of(context).size.width,
                                );
                              }

                          );
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
                  onTap: (){
                    if(!deliveryTime){
                      filterScheduleDeliveryTimes();
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context){
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState){
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
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
                  },
                ),
                now.hour + 1 > 20 || now.hour + 1 < 8? const Text('All stores are currently closed') : const SizedBox.shrink(),
                const Divider(thickness: 1),
                Text(
                  'Shopping preferences',
                  style: Theme.of(context).textTheme.titleLarge,
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
                          Text(value.calculateTotalAmount(false))
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
                          Text(value.totalAmountPlusFees(deliveryTime))
                        ],
                      ),
                      solidButton(context, 'Checkout', () async{
                        await initPayment((double.parse(value.stripEuroSign(value.calculateTotalAmount(deliveryTime))) * 100).toInt().toString(), _auth.getUsername(), context, value);
                      }, true),
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
          'amount': amount ,
          'email': email
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
      _checkout('12 Dalriada Court', 'Tesco', value.cart, value.totalAmountPlusFees(deliveryTime));
    } catch(e){
      print(e);
    }
  }

  void _checkout(String setAddress, String chosenStore, Map<Product, int> products, String amount) async{
    List<Map<String, dynamic>> productListMap = context.read<Cart>().toMapList();
    await _service.openDelivery(setAddress, chosenStore, productListMap, amount);
    context.read<Cart>().clearCart();
    Navigator.of(context).pushReplacement(
        pageAnimationFromTopToBottom(const Home()));
    showToast(text: 'Order Confirmed');
  }


  List<AutocompletePrediction> placePredictions = [];
  void placeAutoComplete(String query) async{
    Uri uri = Uri.https(
        "maps.googleapis.com",
        'maps/api/place/autocomplete/json',
        {
          "input": query,
          "types": "address",
          "key": "AIzaSyDFcJ0SWLhnTZVktTPn8jB5nJ2hpuSfwNk"
        });

    String? response = await NetworkUtility.fetchUrl(uri);

    if (response !=null){
      PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if(result.predictions != null){
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }
}
