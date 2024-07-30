import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/cart/model/cart_model.dart';
import 'package:overlapd/screens/home/models/product_model.dart';
import 'package:overlapd/screens/home/models/store.dart';

class CartProvider extends ChangeNotifier {

  List<CartModel> cart = [];

  // Add item to cart
  void addToCart(CartModel cartModel){
    // if (cartModel == null)
    // Check if the store extist with in the current cart
  bool hasModified = false;
   for (var cartItem in cart) {
    if (cartItem.store.name == cartModel.store.name) {
      cartItem.products.addAll(cartModel.products);
      hasModified = true;
    }
   }
   if (!hasModified) cart.add(cartModel);
   
  }

  // Update firestore record
  Future<bool> updateCartData() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final collection = _firestore.collection('cart');
    final doc = collection.doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      var cartData = cart.map((e) => e.toJson()).toList();
      log(cartData.toString()) ;
      await doc.set({
        'cart': cartData
      });
      return true;
    } catch (e) {
      log("Error: " + e.toString());
      return false;
    }
  }

  // Fetch cart data from firestore
  Future<bool> fetchCartData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('cart');
    final doc = collection.doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      final data = await doc.get();
      if (data.exists) {
        final cartData = data.data()!['cart'] as List;
        cart = cartData.map((e) => CartModel.fromJson(e)).toList();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // @override 
  // Object contains==()

  CartProvider() {
    // Fetch cart data from firestore
    fetchCartData();

    // TODO: Remove Test Data
    cart.add(
      CartModel(
        store: Store(
          name: "Store 1",
          address: "Store 1 Address",
          phone: "Store 1 Phone",
          categories: [],
          email: "Store 1 Email",
          // image: "Store 1 Image",
        ),
        products: [
          Product(
            title: "Product 1",
            price: "100",
            promotionalPrice: "90",
            pricePer: "s",
            productId: 1022,
            productUrl: "Product 1 URL",
            imageUrl: "Product 1 Image",
            store: StoreItemModel(
              name: "Store 1",
              address: "Store 1 Address",
             hierarchy: ["Store 1", "Store 1 Address"],
             image: "Store 1 Image",
            ),
            )          
        ],
      ),

      
    );
    
  }
}
