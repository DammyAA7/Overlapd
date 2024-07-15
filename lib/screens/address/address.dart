import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../utilities/networkUtilities.dart';

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  TextEditingController searchText = TextEditingController();
  String predictions = '';
  List<AutocompletePrediction> placePredictions = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: MediaQuery.of(context).size.height * 0.10,
          title:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back_outlined),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: const Text('Go back'),
                  )
                ],
              ),
            ],
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: searchText,
                    onChanged: (value) async {
                      setState(() {
                        predictions = value;
                        placeAutoComplete(value);
                      });
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Enter a new address",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder( // Adding a border around the TextFormField
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      focusedBorder: OutlineInputBorder( // Border when the TextFormField is focused
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.black, width: 2.0),

                      ),
                    ),
                  ),
                ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: (){

              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.location_on_sharp),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Use my Current Location', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
                                Text('2792 Westhiemer Rd. Santa Ana, Illinois 85486', style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w500), overflow: TextOverflow.visible,
                                  maxLines: 3)
                              ],
                            ),
                          )
                        ],
                      ),
                      Divider()
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Recent addresses', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void placeAutoComplete(String query) async{
    if (query.isEmpty) {
      setState(() {
        placePredictions = [];
      });
      return;
    }
    Uri uri = Uri.https(
        "maps.googleapis.com",
        'maps/api/place/autocomplete/json',
        {
          "input": query,
          "types": "street_address||postal_code||street_number||point_of_interest",
          "location": "53.2779792,-6.3226545", // Latitude and Longitude
          "radius": "5000",
          "strictbounds": "true",
          "components": "country:ie",
          "key": "AIzaSyDFcJ0SWLhnTZVktTPn8jB5nJ2hpuSfwNk"
        });

    String? response = await NetworkUtility.fetchUrl(uri);
    if (response != null){
      PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if(result.predictions != null){
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }
}
