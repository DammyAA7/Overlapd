import 'package:flutter/material.dart';

class Picker extends StatefulWidget {
  static const id = 'picker_page';
  const Picker({super.key});

  @override
  State<Picker> createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title:  Text(
          'List of Orders',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
