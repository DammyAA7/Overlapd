import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/pickers/orders.dart';

import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/toast.dart';
import '../utilities/widgets.dart';

class Picker extends StatefulWidget {
  static const id = 'picker_page';
  const Picker({super.key});

  @override
  State<Picker> createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout_outlined), // You can replace this with your preferred icon
          onPressed: () {
            _signOut();
          },
        ),
        title:  Text(
          'Stores',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          selectStoreTile(context, 'supervalu.png', 'SuperValu'),
          selectStoreTile(context, 'tesco.png', 'Tesco'),
        ],
      ),
    );
  }

  Widget selectStoreTile(
      BuildContext context,
      String imageName,
      String storeName
      ) {
    return InkWell(
      onTap: (){
        Navigator.push(context, pageAnimationrl(Orders(store: storeName)));
      },
      child: Column(
        children: [
          SizedBox(
            height: 70,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/storeLogos/$imageName')),
                  const Icon(Icons.arrow_forward_ios_outlined)
                ],
              ),
            ),
          ),
          const Divider(thickness: 1)
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await _auth.setLoggedOut();
      await FirebaseAuth.instance.signOut();
      showToast(text: "User logged out successfully");
      Navigator.pushNamed(context, '/login_page');
    } catch (e) {
      await _auth.setLoggedInAsEmployee();
      showToast(text: "An error occurred during sign-out");
      // Handle the exception or show an appropriate message to the user
    }
  }
}
