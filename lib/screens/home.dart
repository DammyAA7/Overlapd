import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/utilities/widgets.dart';
import 'package:overlapd/utilities/toast.dart';


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
      body: Center(
        child: solidButton(context, 'Log out', _signOut, true),
      ),
    );
  }
  void _signOut() async{
    await FirebaseAuth.instance.signOut();
    showToast(text: "User logged out successfully");
    Navigator.pushNamed(context, '/login_page');

  }
}