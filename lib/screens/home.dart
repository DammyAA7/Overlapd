import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  static const id = 'home_page';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: Text(
          'Home',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}