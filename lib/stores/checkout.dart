
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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
  String? setAddress;
  Position? currentLocation;
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
                const Divider(thickness: 1),
                Text(
                  'Shopping preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.all(8.0),
            child: solidButton(context, 'Checkout', () async{
              await initPayment((double.parse(value.stripEuroSign(value.calculateTotalAmount())) * 100).toInt().toString());
            }, true),
          ),
      ),
    );
  }

  Future<void> initPayment(String amount) async{
    print(amount);
    try{
      final response = await http.post(Uri.parse(
          'https://us-central1-overlapd-13268.cloudfunctions.net/StripePaymentIntent'),
        body: {
          'amount': amount
        });

      final jsonResponse = jsonDecode(response.body);
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: 'Overlap Delivery',
          )
      );
      await Stripe.instance.presentPaymentSheet();
    } catch(e){
      print(e);
      showToast(text: '{$e}');
    }
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
