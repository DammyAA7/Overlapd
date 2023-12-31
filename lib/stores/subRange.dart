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
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                pageAnimationrl(Meat(snapshot: widget.subRange[key]!)),
              );
            },
            child: Text(key),
          );
        }).toList(),
      ),
    );
  }
}
