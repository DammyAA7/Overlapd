import 'package:overlapd/screens/home/models/product_model.dart';
import 'package:overlapd/screens/home/models/store.dart';

class CartModel {

  Store store;
  List<Product> products;
  double price = 0;


  CartModel({required this.store, required this.products }) {
    calculatePrice();
  }

  void calculatePrice() {
    price = 0;
    for (var product in products) {
      price += double.parse(product.price.substring(1));
    }
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'store': store.toJson(),
      'products': products.map((e) => e.toJson()).toList(),
      'price': price
    };
  }
}