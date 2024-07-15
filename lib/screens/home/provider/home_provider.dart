import 'dart:developer';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:overlapd/screens/category/widget/shop_bc_widgets.dart';
import 'package:overlapd/screens/home/models/category.dart';
import 'package:overlapd/screens/home/models/store.dart';
import 'package:overlapd/screens/home/widget/home_widgets.dart';

class HomeProvider extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();

  final String API_KEY = "AIzaSyDFcJ0SWLhnTZVktTPn8jB5nJ2hpuSfwNk";

  // In the future we'll have an API call or smth

  List<Store> stores = [];
  List<Category> shopCategoryItems = [];
  late Category _selectedCategory;
  late Store _selectedStore;

  int selectOption = 0;

  bool _emailVerified = false;

  HomeProvider() {
    loadData();

    // final nearestSuperValue =
    //     findNearestTesco(53.349805, -6.26031, API_KEY, 'SuperValu');

    // if (nearestSuperValue != null) {
    //   nearestSuperValue.then((value) async {
    //     if (value != null) {
    //       final String? travelTime = await calculateTravelTime(
    //           53.349805,
    //           -6.26031,
    //           value['geometry']['location']['lat'],
    //           value['geometry']['location']['lng'],
    //           API_KEY);
    //       storeList.add(StoreItemModel(
    //           name: 'SuperValu',
    //           address: value['vicinity'],
    //           image: 'assets/storeLogos/supervalu.png',
    //           distance: travelTime));
    //       notifyListeners();
    //     }
    //   });
    // }

    notifyListeners();
  }

  void selectOptionIndex(int index) {
    selectOption = index;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> findNearestTesco(
      double lat, double lng, String apiKey, String store) async {
    const String placesUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    final Map<String, String> params = {
      'location': '$lat,$lng',
      'radius': '5000', // Search within a 5km radius
      'keyword': store,
      'key': apiKey
    };

    final uri = Uri.parse(placesUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0];
      }
    } else {
      print('Failed to load places: ${response.statusCode}');
    }
    return null;
  }

  Future<String?> calculateTravelTime(double originLat, double originLng,
      double destLat, double destLng, String apiKey) async {
    const String distanceMatrixUrl =
        'https://maps.googleapis.com/maps/api/distancematrix/json';
    final Map<String, String> params = {
      'origins': '$originLat,$originLng',
      'destinations': '$destLat,$destLng',
      'key': apiKey
    };

    final uri = Uri.parse(distanceMatrixUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['rows'][0]['elements'][0]['duration']['text'];
    } else {
      print('Failed to load travel time: ${response.statusCode}');
    }
    return null;
  }

  Future<void> loadData() {
    String fileDirectory = "assets/res.json";
    return rootBundle.loadString(fileDirectory).then((value) {
      List<dynamic> jsonData = jsonDecode(value)["Stores"];
      for (var item in jsonData) {
        stores.add(Store.fromJson(item));
      }

      for (var element in stores) {
        // check if the category is already in the shopCategoryItems

        for (var categoryshop in element.categories) {
          bool isCategoryInShopCategoryItems = false;

          // if (categoryshop in shopCategoryItems)
          for (var cat in shopCategoryItems) {
            if (cat.name == categoryshop.name) {
              isCategoryInShopCategoryItems = true;
              var newCat = categoryshop;
              for (var item in newCat.subCategories) {
                cat.subCategories.add(item);
              }
            }
          }
          if (!isCategoryInShopCategoryItems)  shopCategoryItems.add(categoryshop);
        }

        final nearestTesco =
            findNearestTesco(53.349805, -6.26031, API_KEY, element.name);

        if (nearestTesco != null) {
          nearestTesco.then((value) async {
            if (value != null) {
              final String? travelTime = await calculateTravelTime(
                  53.349805,
                  -6.26031,
                  value['geometry']['location']['lat'],
                  value['geometry']['location']['lng'],
                  API_KEY);
              element.distance = travelTime;
              notifyListeners();
            }
          });
        }
      }

      log(stores.toString());
      notifyListeners();
    });
  }

  void searchStore(String query) {
    List<Store> searchResults = [];
    for (var store in stores) {
      if (store.name.toLowerCase().contains(query.toLowerCase())) {
        searchResults.add(store);
      }
    }
    stores = searchResults;
    notifyListeners();
  }

  void clearSearch() {
    // Not the best way to do this, but it works for now
    stores = [];
    shopCategoryItems = [];
    loadData();
    notifyListeners();
  }

  void searchCategory(String query) {
    List<Category> _categories = [];
    for (var store in stores) {
      _categories.addAll(store.categories);
    }

    List<Category> searchResults = [];
    for (var category in _categories) {
      // chec if the category name contains the query
      if (category.name.toLowerCase().contains(query.toLowerCase())) {
        // check if the category is already in the search results
        if (searchResults.contains(category)) {
          for (var searchResult in searchResults) {
            if (searchResult.name == category.name) {
              searchResult.subCategories.addAll(category.subCategories);
            }
          }
        } else {
          searchResults.add(category);
        }
      }
    }
    shopCategoryItems = searchResults;
    notifyListeners();
  }

  void selectCategory(Category category) {
    _selectedCategory = category;
    searchController.text = category.name;
    notifyListeners();
  }

  void selectStore(Store store) {
    _selectedStore = store;
    notifyListeners();
  }

  Category get selectedCategory => _selectedCategory;
  Store get selectedStore => _selectedStore;
  bool get isEmailVerfied => _emailVerified;
}
