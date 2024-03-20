import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/stores/productListPage.dart';
import 'package:overlapd/stores/shoppingCart.dart';
import 'package:overlapd/stores/range.dart';

import '../utilities/widgets.dart';
import 'groceryRange.dart';

class SubSubRange extends StatefulWidget {
  final Map <String, Future<List<List>>> subRange;
  final String categoryName;
  const SubSubRange({super.key, required this.subRange,required this.categoryName});

  @override
  State<SubSubRange> createState() => _SubSubRangeState();
}

class _SubSubRangeState extends State<SubSubRange> {
  MapRange range = MapRange();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
              context
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title:  Text(
          widget.categoryName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
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
      body: ListView(
        children: widget.subRange.keys.map((key) {
          return InkWell(
            onTap: (){
              Navigator.push(
                  context,
                  pageAnimationrl(Meat(productCSV: widget.subRange[key]!)));
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
                        Flexible(child: Text(key, style: const TextStyle(fontSize: 15))),
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
