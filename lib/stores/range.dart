import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/deliveries/add_delivery_details.dart';
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
                  pageAnimationlr(const DeliveryDetails()),
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
          ],
        ),
      ),
      body: ListView(
        children: widget.groceryRange.keys.map((key) {
          return ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                pageAnimationrl(SubRange(subRange: widget.groceryRange[key]!)),
              );
            },
            child: Text(key),
          );
        }).toList(),
      ),
    );
  }
}
