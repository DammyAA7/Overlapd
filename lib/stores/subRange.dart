import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/stores/productListPage.dart';
import 'package:overlapd/stores/range.dart';
import 'package:overlapd/stores/shoppingCart.dart';
import 'package:overlapd/stores/subSubRange.dart';
import '../utilities/widgets.dart';
import 'groceryRange.dart';

class SubRange extends StatefulWidget {
  final Map<String,Map <String, Future<List<List>>>> subRange;
  final String categoryName;
  const SubRange({super.key, required this.subRange, required this.categoryName});

  @override
  State<SubRange> createState() => _SubRangeState();
}

class _SubRangeState extends State<SubRange> {
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
              context,
              pageAnimationlr(Range(groceryRange: range.tescoGroceryRange)),
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
          return GestureDetector(
            onTap: (){
              Navigator.push(
                  context,
                  pageAnimationrl
                    (SubSubRange(subRange:widget.subRange[key]!, categoryName:key)));
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
