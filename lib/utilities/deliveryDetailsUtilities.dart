import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'networkUtilities.dart';
import 'package:http/http.dart' as http;

class AddressComponents {
  final String? buildingNumber;
  final String? streetAddress;
  final String? locality;
  final String? area;
  final String? postcode;
  final String? fullAddress;

  AddressComponents({
    this.buildingNumber,
    this.streetAddress,
    this.locality,
    this.area,
    this.postcode,
    this.fullAddress
  });
}

Widget locationListTile(String location, VoidCallback press){
  return Column(
    children: [
      ListTile(
        onTap: press,
        horizontalTitleGap: 0,
        title: Text(
          location,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const Divider(
        height: 2,
        thickness: 2,
      )
    ],
  );
}

Future<AddressComponents?> getAddressDetailsFromCoordinates(double latitude, double longitude) async {
  Uri uri = Uri.https(
    "maps.googleapis.com",
    'maps/api/geocode/json',
    {
      "latlng": "$latitude,$longitude",
      "key": "AIzaSyDFcJ0SWLhnTZVktTPn8jB5nJ2hpuSfwNk",
    },
  );

  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      Map<String, dynamic> decodedResponse = json.decode(response.body);
      if (decodedResponse.containsKey("results") &&
          decodedResponse["results"] is List &&
          (decodedResponse["results"] as List).isNotEmpty) {
        // Extract the address components from the first result
        String? buildingNumber;
        String? streetAddress;
        String? locality;
        String? area;
        String? postcode;
        String? fullAddress;

        fullAddress = decodedResponse["results"][0]["formatted_address"];
        List<dynamic> addressComponents = decodedResponse["results"][0]["address_components"];


        for (var component in addressComponents) {
          List<String> types = List<String>.from(component["types"]);
          if (types.contains("street_number")) {
            buildingNumber = component["long_name"];
          } else if (types.contains("route")) {
            streetAddress = component["long_name"];
          } else if (types.contains("neighborhood") || types.contains("locality")) {
            locality = component["long_name"];
          } else if (types.contains("administrative_area_level_1")) {
            area = component["long_name"];
          } else if (types.contains("postal_code")) {
            postcode = component["long_name"];
          }
        }

        return AddressComponents(
          buildingNumber: buildingNumber,
          streetAddress: streetAddress,
          locality: locality,
          area: area,
          postcode: postcode,
          fullAddress: fullAddress
        );
      }
    }
  } catch (e) {
    print(e.toString());
  }
  return null;
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates(this.latitude, this.longitude);

}

Future<Coordinates?> getCoordinates(String address) async {
  Uri uri = Uri.https(
    "maps.googleapis.com",
    'maps/api/geocode/json',
    {
      "address": address,
      "key": "AIzaSyDFcJ0SWLhnTZVktTPn8jB5nJ2hpuSfwNk", // Replace with your Google Maps API key
    },
  );

  try {
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK') {
        var location = data['results'][0]['geometry']['location'];
        double latitude = location['lat'];
        double longitude = location['lng'];
        return Coordinates(latitude, longitude);
      }
    }
  } catch (error) {
    print("Error fetching coordinates: $error");
  }

  return null;
}

class DeliveryDetails {
  late final String distanceToStore;
  late final String storeToDestination;
  late final int totalJourneyTime;

  DeliveryDetails({required this.distanceToStore, required this.storeToDestination, required this.totalJourneyTime});
}

