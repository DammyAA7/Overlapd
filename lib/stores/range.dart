import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/deliveries/add_delivery_details.dart';
import 'package:overlapd/screens/home.dart';
import 'package:overlapd/stores/shoppingCart.dart';
import 'package:overlapd/stores/subRange.dart';

import '../utilities/widgets.dart';

class Range extends StatefulWidget {
  final Map<String, Map<String, Stream<QuerySnapshot>>> groceryRange;
  const Range({super.key, required this.groceryRange});

  @override
  State<Range> createState() => _RangeState();
}

class _RangeState extends State<Range> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                // Navigate to the home page with a fade transition
                Navigator.pushReplacement(
                  context,
                  pageAnimationlr(const Home()),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Tesco',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: (){
                Navigator.push(
                    context,
                    pageAnimationFromBottomToTop(const ShoppingCart())
                );
              },
                icon: const Icon(Icons.shopping_cart_rounded)),
          ],
        ),
      ),
      body: ListView(
        children: widget.groceryRange.keys.map((key) {
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                pageAnimationrl(SubRange(subRange: widget.groceryRange[key]!)));
            },
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(key),
                        const Icon(Icons.arrow_forward_ios_outlined)
                      ],
                    ),
                  ),
                ),
                const Divider(thickness: 1)
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
