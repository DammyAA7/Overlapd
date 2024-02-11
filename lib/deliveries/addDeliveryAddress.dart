import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:overlapd/utilities/toast.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/networkUtilities.dart';
import '../utilities/deliveryDetailsUtilities.dart';
import '../utilities/widgets.dart';

class AddDeliveryAddress extends StatefulWidget {
  const AddDeliveryAddress({super.key});

  @override
  State<AddDeliveryAddress> createState() => _AddDeliveryAddressState();
}

class _AddDeliveryAddressState extends State<AddDeliveryAddress> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  TextEditingController searchText = TextEditingController();
  String? setAddress;
  String? fullAddress;
  Position? currentLocation;
  String? houseNumber;
  String? aptNumber;
  String? streetAddress;
  String? locality;
  String? county;
  String? postalCode;
  String? fullStreetAddress;
  String predictions = '';
  bool defaultAddress = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Navigate to the home page with a fade transition
            setAddress == null ? Navigator.pop(context) :
            setState((){
              setAddress = null;
              searchText.clear();
              predictions = '';
              houseNumber = '';
              streetAddress = '';
              streetAddress = '';
              locality = '';
              county = '';
              postalCode = '';
              fullStreetAddress = null;
            });

          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title:  Text(
          'Address',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: setAddress == null ? Column(
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
                  AddressComponents? formattedAddress = await getAddressDetailsFromCoordinates(currentLocation!.latitude, currentLocation!.longitude);
                  setState(() {
                    setAddress = formattedAddress?.fullAddress;
                    houseNumber = formattedAddress?.buildingNumber;
                    streetAddress = formattedAddress?.streetAddress;
                    locality = formattedAddress?.locality;
                    county = formattedAddress?.area;
                    postalCode = formattedAddress?.postcode;
                    fullStreetAddress = '${houseNumber ?? ''} ${streetAddress ?? ''}';
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
                  itemBuilder: (context,index) {
                    return _buildAddressResult(index);
                  }
              ),
            ),
          ],
        ) : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Street Address"),
              addressInputBox('Street Address', true, false, fullStreetAddress ?? "", TextInputType.streetAddress, (newValue) {
                setState(() {
                  streetAddress = newValue;
                });
              },),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: addressInputBox('Apt, suite or unit', true, false, aptNumber ?? "", TextInputType.number, (newValue) {
                  setState(() {
                    houseNumber = newValue;
                  });
                },),
              ),
              const Text("Locality"),
              addressInputBox('Locality', true, false, locality ?? "", TextInputType.streetAddress, (newValue) {
                setState(() {
                  locality = newValue;
                });
              },),
              const Text("County"),
              addressInputBox('County', true, false, county ?? "", TextInputType.streetAddress, (newValue) {
                setState(() {
                  county = newValue;
                });
              },),
              const Text("Postal code"),
              addressInputBox('Postal code', true, false, postalCode ?? "", TextInputType.streetAddress, (newValue) {
                setState(() {
                  postalCode = newValue;
                });
              },),
              CheckboxListTile(
                value: defaultAddress,
                onChanged: (bool? value){
                  setState(() {
                    defaultAddress = !defaultAddress;
                  });
                },
                title: Text('Set as Default', overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.labelLarge,),
                //contentPadding: const EdgeInsets.only(right: 35),
                //materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
          ],
                ),
        )
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: solidButton(context, "Save Address", () async{
          setState(() {
            fullAddress = '${houseNumber ?? ''} ${streetAddress!}, ${locality!}, ${postalCode!}, ${county!}';
          });
          Map<String, dynamic> addressBook = {
            'Street Address': fullStreetAddress,
            'Locality': locality,
            'County': county,
            'Postal Code': postalCode,
            'Full Address': fullAddress
          };

          await setDefaultAddress(_UID, addressBook, defaultAddress);
          setAddress = null;
          searchText.clear();
          predictions = '';
          houseNumber = '';
          streetAddress = '';
          streetAddress = '';
          locality = '';
          county = '';
          postalCode = '';
          fullStreetAddress = null;
          Navigator.pop(context);
          Navigator.pop(context);
        }
            , fieldsFilled()),
      ),
    );
  }
  List<AutocompletePrediction> placePredictions = [];
  void placeAutoComplete(String query) async{
    Uri uri = Uri.https(
        "maps.googleapis.com",
        'maps/api/place/autocomplete/json',
        {
          "input": query,
          "types": "street_address||postal_code||street_number||point_of_interest",
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


  Widget _buildAddressResult(int index){
    placeAutoComplete(predictions);
    if(predictions.isEmpty){
      return const SizedBox.shrink();
    }
    else{
      return locationListTile(placePredictions[index].description!, () {
        setAddress = placePredictions[index].description;
        //getCoordinates(setAddress!);
        houseNumber = placePredictions[index].terms?.buildingNumber;
        streetAddress = placePredictions[index].terms?.streetAddress;
        locality = placePredictions[index].terms?.locality;
        county = placePredictions[index].terms?.area;
        fullStreetAddress = '${houseNumber ?? ''} ${streetAddress ?? ''}';

      });
    }
  }

  bool fieldsFilled() {
    List<String?> fields = [setAddress, fullStreetAddress, locality, county, postalCode];
    return fields.every((field) => field != null && field.isNotEmpty);
  }

  Future<void> setDefaultAddress(String userId, Map<String, dynamic> newAddress, bool defaultAddress) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists && docSnapshot.data()!.containsKey('Address Book')) {
      List<dynamic> addressBook = List<dynamic>.from(docSnapshot.data()!['Address Book']);

      // Check for address uniqueness before adding/updating
      bool addressExists = addressBook.any((address) {
        return Map<String, dynamic>.from(address)['Full Address'] == newAddress['Full Address'];
      });

      if (addressExists) {
        // Address already exists, inform the user or update the existing address
        showToast(text: 'This address already exists.');
        return; // Stop the function execution
      }

      // If defaultAddress is true, reset Default flag for all existing addresses
      if (defaultAddress) {
        addressBook = addressBook.map((address) {
          final Map<String, dynamic> modifiedAddress = Map<String, dynamic>.from(address);
          modifiedAddress['Default'] = false; // Reset default flag for all other addresses
          return modifiedAddress;
        }).toList();
      }
      // Add new address with its default status
      newAddress['Default'] = defaultAddress;
      addressBook.add(newAddress);

      // Update the Address Book in Firestore with the modified list
      await userDoc.update({'Address Book': addressBook});

    } else {
      // If no Address Book exists or the document doesn't exist, create one with the new address
      newAddress['Default'] = defaultAddress;
      await userDoc.set({'Address Book': [newAddress]});
    }
  }




}
