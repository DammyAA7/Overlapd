import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class MapRange{
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Map<String, Map<String, Stream<QuerySnapshot>>> tescoGroceryRange = {};
  Map<String, Map<String, Stream<QuerySnapshot>>> supervaluGroceryRange = {};

  MapRange(){
    tescoGroceryRange ={
      'Pets': {
        'Cats & Kitten': streamTesco('Pets', 'Cats&Kitten'),
        'Dog & Puppy':streamTesco('Pets', 'Dog & Puppy'),
        'Small Animal, Fish & Bird':streamTesco('Pets', 'Small Animal, Fish & Bird'),
        'Christmas for Pets':streamTesco('Pets', 'Christmas for Pets'),
        'Offers on Pets':streamTesco('Pets', 'Offers on Pets'),
      },
      'Tesco Finest':{
        'Finest Fresh Food': streamTesco('TescoFinest', 'Finest Fresh Food'),
        'Finest Bakery': streamTesco('TescoFinest', 'Finest Bakery'),
        'Finest Drinks': streamTesco('TescoFinest', 'Finest Drinks'),
        'Finest Food Cupboard': streamTesco('TescoFinest', 'FinestFoodCupboard'),
        'Finest Frozen Food': streamTesco('TescoFinest', 'Finest Frozen Food'),

      }
    };

    supervaluGroceryRange = {
      'Fruits & Vegetables' : {
        'Fruit': streamTesco('Pets', 'Cats&Kitten'),
        'Vegetables': streamTesco('Pets', 'Cats&Kitten'),
        'Potatoes': streamTesco('Pets', 'Cats&Kitten'),
        'Salads': streamTesco('Pets', 'Cats&Kitten'),
        'Herbs': streamTesco('Pets', 'Cats&Kitten'),
        'Fresh Flowers': streamTesco('Pets', 'Cats&Kitten')
      },
      'Bakery': {
        'Bread': streamTesco('Pets', 'Cats&Kitten'),
        'Fresh In Store Bakery':streamTesco('Pets', 'Cats&Kitten'),
        'Packaged Cakes & Treats': streamTesco('Pets', 'Cats&Kitten')
      }

    };

  }

  Stream<QuerySnapshot> streamTesco(String document, String subCollection) {
    return fireStore.collection('Tesco').doc(document).collection(subCollection).snapshots();
  }


}

class Product {
  final String title;
  final double price;
  final String pricePer;
  final String imageUrl;

  Product({
    required this.title,
    required this.price,
    required this.pricePer,
    required this.imageUrl
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Product &&
              runtimeType == other.runtimeType &&
              title == other.title &&
              price == other.price &&
              pricePer == other.pricePer &&
              imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      title.hashCode ^ price.hashCode ^ pricePer.hashCode ^ imageUrl.hashCode;
}

class Cart extends ChangeNotifier{
  Map<Product, int> cart = {};

  void addToCart(Product product, int quantity){
    if (cart.containsKey(product)) {
      // If the product exists, update the quantity
      cart.update(product, (existingQuantity) => existingQuantity + quantity);
    } else {
      // If the product doesn't exist, add it to the cart
      cart[product] = quantity;
    }
  }

  void removeFromCart(Product product){
    cart.remove(product);
  }

  void updateQuantity(Product product, int quantity){
    cart.update(product, (value) => quantity);
  }

  String calculateTotalAmount() {
    double totalAmount = 0;
    cart.forEach((product, quantity) {
      totalAmount += product.price * quantity;
    });
    String formattedTotalAmount = '€${totalAmount.toStringAsFixed(2)}';
    return formattedTotalAmount;
  }

}


