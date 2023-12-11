import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/deliveries/delivery_service.dart';
import 'package:overlapd/screens/side_bar.dart';
import 'package:overlapd/utilities/toast.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';

class Home extends StatefulWidget {
  static const id = 'home_page';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final DeliveryService _service = DeliveryService();
  late String _UID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBar(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Home',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined), // You can replace this with your preferred icon
              onPressed: () {
                _signOut();
              },
            ),

          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
          child:Column(
            children: [
              Expanded(child: _buildList()),
              const Text('Loading'),
              solidButton(context, 'Request Delivery', _requestDelivery, true),
            ],
          )
      ),
    );
  }

  void _requestDelivery() async{
    if(await _auth.isLoggedIn()){
      await _service.openDelivery();
      print('logged in');
    } else{
      print('not');
    }

  }

  void _signOut() async {
    try {
      await _auth.setLoggedOut();
      await FirebaseAuth.instance.signOut();
      showToast(text: "User logged out successfully");
      Navigator.pushNamed(context, '/login_page');
    } catch (e) {
      await _auth.setLoggedIn();
      showToast(text: "An error occurred during sign-out");
      // Handle the exception or show an appropriate message to the user
    }
  }
  
  Widget _buildList(){
    return StreamBuilder(
        stream: _service.getRequestedDeliveries(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the data is still loading, return a loading indicator
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            // If there is no data or the data is empty, display a message
            return const Text('No deliveries available');
          } else {
            // If data is available, build the ListView
            return ListView(
              children: snapshot.data!.docs.map((document) => _buildItem(document)).toList(),
            );
          }
        });
  }

  Widget _buildItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    print('Data User ID: ${data['Placed by']}');
    print('Current User ID: $_UID');

    return data['Placed by'] != _UID ? Container(
      alignment: Alignment.center,
      child: Column(
        children: [
           Text(data['Delivery Location'])
        ],
      ),
    ) : const SizedBox.shrink();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
    _buildList();
  }

  Future<void> _init() async {
    _UID = (await _auth.getUserId())!;
  }
}
