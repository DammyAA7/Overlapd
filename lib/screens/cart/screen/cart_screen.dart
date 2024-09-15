import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/screens/cart/model/cart_model.dart';
import 'package:overlapd/screens/cart/provider/cart_provider.dart';
import 'package:overlapd/utilities/customButton.dart';
import 'package:overlapd/utilities/widgets.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
         const Align(
            alignment: Alignment.centerLeft,
            child:  Padding(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Text("My Cart",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15
              ),
              ),
            ),
          ),
          Consumer<CartProvider>(
            builder:(context, provider, child) {
                return Expanded(child: ListView.builder(
                  itemCount: provider.cart.length,
                  itemBuilder: (context, index) {
                    return _cartItem(context, provider.cart[index]);
                  }
                   ));
            },

          )
        ],
      ),
    );
  }
}

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: MediaQuery.of(context).size.height * 0.10,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_outlined),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('Go back'),
          )
        ],
      ),
    );
  }

  Widget _cartItem(BuildContext context, CartModel cartItem) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.symmetric(
        horizontal: 11.0,
        vertical: 17.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 40.0,
                width: 40.0,
                margin: const EdgeInsets.only(
                  top: 15.0,
                  bottom: 15.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 11.0,
                  top: 2.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.store.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff535353)
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text(
                          "${cartItem.products.length} items",
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff535353)
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: SizedBox(
                            height: 1.0,
                            width: 1.0,
                            child: VerticalDivider(
                              color: Colors.black,
                              width: 1.0,
                              thickness: 1.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                           "Euro " + cartItem.price.toString(),  
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff535353)
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    const Text(
                      "Delivery in 2 days",
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff535353)
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 44.0),
            child:  Icon(
              Icons.delete_forever_outlined,
              size: 24,
             
            ),
          ),
          const SizedBox(height: 28.0),
          CustomElevatedButton(
            text: "Checkout",
            onPressed: () {

            }
          ),
          const SizedBox(height: 14.0),
          // Text(
          //   checkoutListItemModelObj.reviewItemsClic!,
          //   style: CustomTextStyles.titleSmallMedium,
          // ),
          const SizedBox(height: 18.0),
        ],
      ),
    );

  }