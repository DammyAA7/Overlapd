import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'networkUtilities.dart';

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

Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
  Uri uri = Uri.https(
    "maps.googleapis.com",
    'maps/api/geocode/json',
    {
      "latlng": "$latitude,$longitude",
      "key": "AIzaSyDFcJ0SWLhnTZVktTPn8jB5nJ2hpuSfwNk",
    },
  );

  String? response = await NetworkUtility.fetchUrl(uri);

  if (response != null) {
    Map<String, dynamic> decodedResponse = json.decode(response);
    if (decodedResponse.containsKey("results") &&
        decodedResponse["results"] is List &&
        (decodedResponse["results"] as List).isNotEmpty) {
      // Extract the first formatted address from the results
      return decodedResponse["results"][0]["formatted_address"];
    }
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