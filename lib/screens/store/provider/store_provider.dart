import 'package:flutter/material.dart';
import 'package:overlapd/screens/home/models/store.dart';
import 'package:overlapd/screens/home/widget/home_widgets.dart';

class StoreScreenProvider extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();

  List<Store> storeInventory = [];

  StoreScreenProvider() {}

  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void searchPage(String query) {
    storeInventory = storeInventory.where((store) {
      return store.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    notifyListeners();
  }
}
