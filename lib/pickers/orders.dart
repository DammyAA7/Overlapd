import 'package:flutter/material.dart';
import 'package:overlapd/pickers/picker.dart';

import '../utilities/widgets.dart';

class Orders extends StatefulWidget {
  final String store;
  const Orders({super.key, required this.store});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Navigate to the home page with a fade transition
            Navigator.pushReplacement(
              context,
              pageAnimationlr(const Picker()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title:  Text(
          '${widget.store} Orders',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
