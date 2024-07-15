import 'package:flutter/material.dart';
import 'package:overlapd/screens/category/model/shop_by_category_model.dart';
import 'package:provider/provider.dart';

class ShopByCategoryProvider extends ChangeNotifier {
  TextEditingController searchController = TextEditingController(text: "");

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  ShopByCategoryProvider() {
    // Call HomeProvider and get the current category "without" context

    // final CallbackAction
  }
}
