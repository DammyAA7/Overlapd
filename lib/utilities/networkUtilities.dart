import 'package:http/http.dart' as http;
import 'dart:convert';
import '';
class NetworkUtility{
  static Future<String?> fetchUrl(Uri uri, {Map<String, String>? headers}) async{
    try{
      final response = await http.get(uri, headers: headers);
      if(response.statusCode == 200){
        return response.body;
      }
    } catch(e){
      print(e.toString());
    }
    return null;
  }
}

class PredictionTerms {
  final String? buildingNumber;
  final String? streetAddress;
  final String? locality;
  final String? area;

  PredictionTerms({
    this.buildingNumber,
    this.streetAddress,
    this.locality,
    this.area,
  });

  factory PredictionTerms.fromJson(List<dynamic> terms) {
    String? buildingNumber;
    String? streetAddress;
    String? locality;
    String? area;

    // Assuming the terms are ordered as per your specification:
    // 0: Building Number (if exists)
    // 1: Street Address (if exists)
    // 2: Locality
    // 3: Area
    if (terms.isNotEmpty) {
      // Initialize all values to null to handle cases with less than 4 terms
      buildingNumber = null;
      streetAddress = null;
      locality = null;
      area = null;

      // Assign values based on available terms
      // The index is checked against the length of terms to avoid out-of-bounds access
      if (terms.length == 4 && RegExp(r'^\d+$').hasMatch(terms.first['value'])) {
        // If there are 4 terms and the first is a building number, assign values accordingly
        buildingNumber = terms.first['value'];
        streetAddress = terms[1]['value'];
        area = terms[2]['value']; // Assuming the third term is the area if locality is missing
        locality = null; // Locality is left as null
      } else {
        buildingNumber = terms.length > 4 ? terms[0]['value'] : null;
        streetAddress = terms.length > 3 ? terms[terms.length - 4]['value'] : null;
        locality = terms.length > 2 ? terms[terms.length - 3]['value'] : null;
        area = terms.length > 1 ? terms[terms.length - 2]['value'] : null;
      }
    }
    return PredictionTerms(
      buildingNumber: buildingNumber,
      streetAddress: streetAddress,
      locality: locality,
      area: area,
    );
  }
}

class AutocompletePrediction{
  final String? description;
  final StructuredFormatting? structuredFormatting;
  final String? placeId;
  final String? reference;
  final PredictionTerms? terms;

  AutocompletePrediction({
    this.description,
    this.structuredFormatting,
    this.placeId,
    this.reference,
    this.terms,
  });

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      description: json['description'] as String?,
      placeId: json['place_id'] as String?,
      reference: json['reference'] as String?,
      structuredFormatting: json['structured_formatting'] != null
          ? StructuredFormatting.fromJson(json['structured_formatting'])
          : null,
      terms: json['terms'] != null // Check if terms exist and parse accordingly
          ? PredictionTerms.fromJson(json['terms'])
          : null,
    );
  }
}

class StructuredFormatting {
  /// [mainText] contains the main text of a prediction, usually the name of the place.
  final String? mainText;

  /// [secondaryText] contains the secondary text of a prediction, usually the location of the place.
  final String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'] as String?,
      secondaryText: json['secondary_text'] as String?,
    );
  }
}

class PlaceAutocompleteResponse {
  final String? status;
  final List<AutocompletePrediction>? predictions;

  PlaceAutocompleteResponse({this.status, this.predictions});

  factory PlaceAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteResponse(
      status: json['status'] as String?,
      // ignore: prefer_null_aware_operators
      predictions: json['predictions'] != null
          ? json['predictions']
          .map<AutocompletePrediction>(
              (json) => AutocompletePrediction.fromJson(json))
          .toList()
          : null,
    );
  }

  static PlaceAutocompleteResponse parseAutocompleteResult(
      String responseBody) {
    final parsed = json.decode(responseBody).cast<String, dynamic>();

    return PlaceAutocompleteResponse.fromJson(parsed);
  }
}

class DistanceMatrixResponse {
  final List<String>? destinationAddresses;
  final List<String>? originAddresses;
  final List<DistanceMatrixElement>? elements;
  final String? status;

  DistanceMatrixResponse({
    this.destinationAddresses,
    this.originAddresses,
    this.elements,
    this.status,
  });

  factory DistanceMatrixResponse.fromJson(Map<String, dynamic> json) {
    return DistanceMatrixResponse(
      destinationAddresses: List<String>.from(json["destination_addresses"]),
      originAddresses: List<String>.from(json["origin_addresses"]),
      elements: json["rows"] != null ? (json["rows"][0]["elements"] as List).map((e) => DistanceMatrixElement.fromJson(e)).toList() : [],
      status: json["status"],
    );
  }
}

class DistanceMatrixElement {
  final DistanceInfo? distance;
  final DurationInfo? duration;
  final String? status;

  DistanceMatrixElement({this.distance, this.duration, this.status});

  factory DistanceMatrixElement.fromJson(Map<String, dynamic> json) {
    return DistanceMatrixElement(
      distance: DistanceInfo.fromJson(json["distance"]),
      duration: DurationInfo.fromJson(json["duration"]),
      status: json["status"],
    );
  }
}

class DistanceInfo {
  final String? text;
  final int? value;

  DistanceInfo({this.text, this.value});

  factory DistanceInfo.fromJson(Map<String, dynamic> json) {
    return DistanceInfo(
      text: json["text"],
      value: json["value"],
    );
  }
}

class DurationInfo {
  final String? text;
  final int? value;

  DurationInfo({this.text, this.value});

  factory DurationInfo.fromJson(Map<String, dynamic> json) {
    return DurationInfo(
      text: json["text"],
      value: json["value"],
    );
  }
}
