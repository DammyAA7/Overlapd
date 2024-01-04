import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/stores/productListPage.dart';
import 'package:overlapd/stores/range.dart';
import '../utilities/widgets.dart';
import 'groceryRange.dart';

class SubRange extends StatefulWidget {
  final Map<String, Stream<QuerySnapshot>> subRange;
  const SubRange({super.key, required this.subRange});

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
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  pageAnimationlr(Range(groceryRange: range.tescoGroceryRange)),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Sub Range',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: widget.subRange.keys.map((key) {
          return GestureDetector(
            onTap: (){
              Navigator.push(
                  context,
                  pageAnimationrl(Meat(snapshot: widget.subRange[key]!)));
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
