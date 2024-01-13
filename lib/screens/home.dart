import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:overlapd/deliveries/add_delivery_details.dart';
import 'package:overlapd/deliveries/delivery_service.dart';
import 'package:overlapd/utilities/toast.dart';
import '../stores/groceryRange.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';
import 'package:overlapd/utilities/homeUtilities.dart';
import 'package:overlapd/stores/range.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  static const id = 'home_page';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}



class _HomeState extends State<Home> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final DeliveryService _service = DeliveryService();
  late final String _UID = _auth.getUserId();
  String? firstName;
  Position? currentPosition;
  MapRange range = MapRange();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _buildList();
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer:buildDrawer(context, 'Ade Bayo'),
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
            child:Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius:  BorderRadius.circular(20),
                            ),
                            child: TabBar(
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorWeight: 4.0,
                              indicator: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),

                                labelColor: Colors.white,
                                tabs: const [
                                  Tab(child: Text('Order', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                                  Tab(child: Text('Deliver', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                                ]
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: TabBarView(
                            children: [
                              Column(
                                children: [
                                  selectStoreTile(context, 'supervalu.png', range.supervaluGroceryRange, 'SuperValu'),
                                  selectStoreTile(context, 'tesco.png', range.tescoGroceryRange, 'Tesco'),
                                ],
                              ),
                              true ? Column(
                                children: [
                                  solidButton(context, 'Verify Identity', () async{
                                    try{
                                      final response = await http.post(Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeIdentity'));
                                      final jsonResponse = jsonDecode(response.body);
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(_UID)
                                          .set({'Stripe Identity Id': jsonResponse['id']}, SetOptions(merge: true));
                                      launchUrl(Uri.parse(jsonResponse['url']), mode: LaunchMode.inAppBrowserView);
                                    } catch(e) {
                                      print(e);
                                    }
                                  }, true),
                                  const SizedBox(height: 10),
                                  solidButton(context, 'Create Stripe Express Account', () async{
                                    try{
                                      final accountResponse = await http.post(
                                          Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeCreateConnectAccount'),
                                          body: {
                                            'uid': _UID,
                                            'email': _auth.getUsername()
                                          }
                                      );
                                      final jsonAccountResponse = jsonDecode(accountResponse.body);
                                      print(jsonAccountResponse);
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(_UID)
                                          .set({'Stripe Account Id': jsonAccountResponse['id']}, SetOptions(merge: true));
                                      final accountLinkResponse = await http.post(
                                          Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeCreateAccountLink'),
                                          body: {
                                            'account': jsonAccountResponse['id'],
                                          }
                                      );
                                      final jsonAccountLinkResponse = jsonDecode(accountLinkResponse.body);
                                      print(jsonAccountLinkResponse);
                                      launchUrl(Uri.parse(jsonAccountLinkResponse['url']), mode: LaunchMode.inAppBrowserView);
                                    } catch(e) {
                                      print(e);
                                    }
                                  }, true)
                                ],
                              ) : _buildList()
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(flex:5, child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)
                        ),
                      child: const Text('Recent Activity')
                      ),
                  )
                  ),
                  Expanded(flex:1, child: _requestDeliveryButton())
                ],
              ),
            )
        ),
      ),
    );
  }

  GestureDetector selectStoreTile(
      BuildContext context,
      String imageName,
      Map<String, Map<String, Stream<QuerySnapshot>>> range,
      String storeName
      ) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          pageAnimationrl(Range(groceryRange: range, storeName: storeName)),
        );
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

  void _requestDelivery() async{
    try {
      await getCurrentLocation();
      // Proceed with delivery request logic as location services are enabled
      Navigator.of(context).pushReplacement(
        pageAnimationFromBottomToTop(const DeliveryDetails()),
      );
    } catch (e) {
      // Display a message to the user about the location issue
      showToast(text: e.toString());
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

  void acceptDelivery(String orderID) async{
    try {
      //check if location services are enabled
      currentPosition = await getCurrentLocation();
      // Retrieve the value of 'Placed by' from 'All Deliveries' collection
      DocumentSnapshot deliverySnapshot = await FirebaseFirestore.instance
          .collection('All Deliveries')
          .doc('Open Deliveries')
          .collection('Order Info')
          .doc(orderID)
          .get();
      if (deliverySnapshot.exists) {
        String placedByUserID = deliverySnapshot['Placed by'];
        String address = deliverySnapshot['Delivery Address'];

        // Update 'accepted by' field in the user's 'Placed Delivery' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(placedByUserID)
            .collection('Placed Delivery')
            .doc(orderID)
            .update({'accepted by': _UID});

        // Update 'accepted by' field in 'All Deliveries' collection
        await FirebaseFirestore.instance
            .collection('All Deliveries')
            .doc('Open Deliveries')
            .collection('Order Info')
            .doc(orderID)
            .update({'accepted by': _UID});

        _service.acceptDelivery(address, _UID, placedByUserID, orderID);

        showToast(text: 'Delivery accepted successfully');
      } else {
        showToast(text: 'Delivery not found');
      }
    } catch (e) {
      print('Error accepting delivery: $e');
      showToast(text: 'Error accepting delivery');
    }
  }

  void declineDelivery(String orderID) async{
    await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .doc(orderID)
        .update({
      'declined By': FieldValue.arrayUnion([_UID]),
    });

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

            bool hasAcceptedDelivery = snapshot.data!.docs.any((document) {
              Map<String, dynamic> data = document.data() as Map<String,
                  dynamic>;
              return data['accepted by'] == _UID;
            });

            bool hasPendingDelivery = snapshot.data!.docs.any((document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return data['Placed by'] == _UID && data['complete'] == 'no' &&
                  data['cancelled'] == 'no';
            });

            bool hasAcceptedPendingDelivery = snapshot.data!.docs.any((document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return data['accepted by'] != _UID && data['accepted by'] != 'N/A';
            });
            if (hasAcceptedDelivery) {
              DocumentSnapshot activeOrderDocument = snapshot.data!.docs.firstWhere(
                      (document) {
                        Map<String, dynamic> data = document.data() as Map<
                            String,
                            dynamic>;
                        return data['accepted by'] == _UID;
                      },
              );
              String orderID = activeOrderDocument.id;
              String placedByUser = activeOrderDocument['Placed by'];
              String acceptedByUser = activeOrderDocument['accepted by'];
              String deliveryAddress = activeOrderDocument['Delivery Address'];
              List itemList = activeOrderDocument['Items for Delivery'];
              return activeDeliveryCard(placedByUser, orderID, acceptedByUser, deliveryAddress, itemList);
            }else if(hasPendingDelivery){
              if(hasAcceptedPendingDelivery){
                DocumentSnapshot activeOrderDocument = snapshot.data!.docs.firstWhere(
                      (document) {
                    Map<String, dynamic> data = document.data() as Map<
                        String,
                        dynamic>;
                    return data['Placed by'] == _UID;
                  },
                );
                String orderID = activeOrderDocument.id;
                String acceptedByUser = activeOrderDocument['accepted by'];
                String placedByUser = activeOrderDocument['Placed by'];
                return activeDeliveryStatusCard(acceptedByUser, orderID, placedByUser);
              } else{
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: const Text('Order Requested\n We will notify you when the order has been accepted'),
                  ),
                );
              }
            } else {
              return ListView(
                children: snapshot.data!.docs.map((document) {
                  return _buildItem(document);
                }).toList(),
              );
            }
          }
        });
  }

  Widget _buildItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String orderNo = document.id;
    return data['Placed by'] != _UID && data['accepted by'] == 'N/A' && !data['declined By']?.contains(_UID) ? Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          height: 140,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color(0xFF21D19F).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            children: [
               Text(data['Grocery Store']),
              Text(data['Item Total']),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
              [
                ElevatedButton(onPressed: () => declineDelivery(orderNo), child: const Text('Decline')),
                ElevatedButton(onPressed: () => acceptDelivery(orderNo), child: const Text('Accept'))
              ],)
            ],
          ),
        ),
      ),
    ) : const SizedBox.shrink();
  }



  Widget _requestDeliveryButton(){
    return StreamBuilder(
      stream: _service.getRequestedDeliveries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the data is still loading, return a loading indicator
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If there's an error, display an error message
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
          // If there is no data or the data is empty, display a message
          return solidButton(context, 'Request Delivery', _requestDelivery, true);
        } else {
          // If data is available, build the button based on the current document
          bool hasPendingDelivery = snapshot.data!.docs.any((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return data['Placed by'] == _UID && data['complete'] == 'no' &&
                data['cancelled'] == 'no';
          });

          bool hasAcceptedDelivery = snapshot.data!.docs.any((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return data['accepted by'] == _UID;
          });

          if (hasAcceptedDelivery) {
            return const SizedBox.shrink();
          }
          else if(hasPendingDelivery) {
            return solidButton(
                context, 'Cancel Delivery Request', _cancelDelivery, true);
          }else{
        return solidButton(
        context, 'Request Delivery', _requestDelivery, true);
          }
        }
      }
    );
  }


void _cancelDelivery() async{
  final latestPlacedDelivery = await _service.getLatestPlacedDelivery(_UID);

  if (latestPlacedDelivery != null) {
    // Update the 'cancelled' field to 'yes'
    await FirebaseFirestore.instance
        .collection('All Deliveries')
        .doc('Open Deliveries')
        .collection('Order Info')
        .doc(latestPlacedDelivery).delete();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_UID)
        .collection('Placed Delivery')
        .doc(latestPlacedDelivery).update({'cancelled' : 'yes'});
  } else {
    print('No placed deliveries found for user $_UID');
  }
}


}


