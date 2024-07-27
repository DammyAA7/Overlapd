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

  // @override 
  // Object contains==()

  CartProvider() {
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
