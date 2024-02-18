import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:overlapd/deliveries/add_delivery_details.dart';
import 'package:overlapd/deliveries/delivery_service.dart';
import 'package:overlapd/utilities/toast.dart';
import '../stores/groceryRange.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/deliveryDetailsUtilities.dart';
import '../utilities/networkUtilities.dart';
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
  String? name;
  Position? currentPosition;
  MapRange range = MapRange();
  bool isVerified = true;
  bool hasAccount = true;
  List modeOfTransport = ['driving', 'walking', 'bicycling', 'transit'];
  String chosenMode = 'driving';
  Position? currentLocation;
  String? distanceToStore;
  String? storeToDestination;
  int totalJourneyTime = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
    _buildList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer:buildDrawer(context, name ?? 'Name'),
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
                          flex: 10,
                          child: TabBarView(
                            children: [
                              Column(
                                children: [
                                  selectStoreTile(context, 'supervalu.png', range.supervaluGroceryRange, 'SuperValu'),
                                  selectStoreTile(context, 'tesco.png', range.tescoGroceryRange, 'Tesco'),
                                ],
                              ),
                              _isVerifiedHasAccount()
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  _requestDeliveryButton()
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
      Map<String, Map<String,Map <String, Future<List<List>>>>> range,
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



  Widget _identityStatus(){
    return StreamBuilder(
        stream: _auth.getAccountInfo(_UID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the data is still loading, return a loading indicator
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null ) {
            // If there is no data or the data is empty, display a message
            return const Text('No deliveries available');
          }else {
            // Access the status value from the snapshot
            bool fieldExist = true;
            try{
              snapshot.data?.get('Stripe Identity Status');
            } catch(e){
              fieldExist = false;
            }
            String status;
            if(fieldExist){
              status = snapshot.data!['Stripe Identity Status'];
            } else{
              return solidButton(context, 'Verify Identity', () async{
                try{
                  final response = await http.post(
                      Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeIdentity'),
                      body: {
                        'uid': _UID
                      }
                  );
                  final jsonResponse = jsonDecode(response.body);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_UID)
                      .set({'Stripe Identity Id': jsonResponse['id']}, SetOptions(merge: true));
                  launchUrl(Uri.parse(jsonResponse['url']), mode: LaunchMode.inAppBrowserView);
                } catch(e) {
                  print(e);
                }
              }, true);
            }
            // Determine the button text and enable status based on the 'Stripe Identity Status'
            String buttonText = '';
            bool isButtonEnabled = false;

            if (status == 'processing' || status == 'verified') {
              buttonText = status;
              isButtonEnabled = false;
              if(status == 'verified'){
                isVerified = false;
              }
            } else {
              buttonText = 'Verify Identity';
              isButtonEnabled = true; // Set this to false if you want to disable the button
            }

            return solidButton(context, buttonText, () async{
              try{
                final response = await http.post(
                    Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeIdentity'),
                    body: {
                      'uid': _UID
                    }
                );
                final jsonResponse = jsonDecode(response.body);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_UID)
                    .set({'Stripe Identity Id': jsonResponse['id']}, SetOptions(merge: true));
                launchUrl(Uri.parse(jsonResponse['url']), mode: LaunchMode.inAppBrowserView);
              } catch(e) {
                print(e);
              }
            }, isButtonEnabled);
          }
        },
    );
  }

  Widget _expressAccount(){
    return StreamBuilder(
      stream: _auth.getAccountInfo(_UID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the data is still loading, return a loading indicator
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If there's an error, display an error message
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null ) {
          // If there is no data or the data is empty, display a message
          return const Text('No data available');
        }else {
          // Access the status value from the snapshot
          bool fieldExist = true;
          String id = '';
          try{
            snapshot.data?.get('Stripe Account Id');
            id = snapshot.data!['Stripe Account Id'];
          } catch(e){
            fieldExist = false;
            print(e);
          }
          if(id.isNotEmpty && fieldExist){
            hasAccount = false;
            return solidButton(context, 'Account Created', () async{
              try{
                final accountResponse = await http.post(
                    Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeCreateConnectAccount'),
                    body: {
                      'uid': _UID,
                      'email': _auth.getUsername()
                    }
                );
                final jsonAccountResponse = jsonDecode(accountResponse.body);
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
                launchUrl(Uri.parse(jsonAccountLinkResponse['url']), mode: LaunchMode.inAppBrowserView);
              } catch(e) {
                print(e);
              }
            }, false);
          }
           else{
            return solidButton(context, 'Create Stripe Account', () async{
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
            }, true);
          }
        }
      },
    );
  }
  Widget _isVerifiedHasAccount(){
    return StreamBuilder(
        stream: _auth.getAccountInfo(_UID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the data is still loading, return a loading indicator
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            // If there is no data or the data is empty, display a message
            return const Text('No deliveries available');
          } else {
            try{
              String identityStatus = snapshot.data!['Stripe Identity Status'];
              String accountId = snapshot.data!['Stripe Account Id'];

              if (identityStatus == 'verified' && accountId.isNotEmpty) {
                return _buildList();
              } else {
                return Column(
                  children: [
                    _identityStatus(),
                    const SizedBox(height: 10),
                    _expressAccount()
                  ],
                );
              }
            } catch(e){
              return Column(
                children: [
                  _identityStatus(),
                  const SizedBox(height: 10),
                  _expressAccount()
                ],
              );
            }
          }
        }
    );
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
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Order Requested\n We will notify you when the order has been accepted'),
                );
              }
            } else {
              return Column(
                children: [
                  DropdownButtonFormField2<String>(
                    decoration: InputDecoration(
                      // Add Horizontal padding using menuItemStyleData.padding so it matches
                      // the menu padding when button's width is not specified.
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // Add more decoration..
                    ),
                    isExpanded: true,
                    hint: const Text(
                      'Select a mode of transport',
                      style: TextStyle(fontSize: 20),
                    ),
                    items: modeOfTransport.map((store)
                    => DropdownMenuItem<String>(
                      value: store,
                      child: Text(store, style: const TextStyle(fontSize: 20)),
                    )
                    ).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select store';
                      }
                      return null;
                    },
                    onChanged: (newValue){
                      setState(() {
                        chosenMode = newValue.toString();
                      });
                    },
                    onSaved: (value) {
                      chosenMode = value.toString();
                    },
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.only(right: 8),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black45,
                      ),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      elevation: 0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: snapshot.data!.docs.map((document) {
                        return _buildItem(document);
                      }).toList(),
                    ),
                  ),
                ],
              );
            }
          }
        });
  }

  Widget _buildItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String orderNo = document.id;
    Future<DeliveryDetails> deliveryDetails = getDistanceTime(data['Delivery Address']);
    return FutureBuilder<DeliveryDetails>(
      future: deliveryDetails,
      builder: (BuildContext context, AsyncSnapshot<DeliveryDetails> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Assuming snapshot.data now contains the DeliveryDetails object
          DeliveryDetails deliveryDetails = snapshot.data!;
          return data['Placed by'] != _UID && data['accepted by'] == 'N/A' && !data['declined By']?.contains(_UID) ? Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFF21D19F).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['Grocery Store']),
                      Text('Distance to Store: ${deliveryDetails.distanceToStore}'),
                      Text('Distance from Store to Destination: ${deliveryDetails.storeToDestination}'),
                      Text('Total Journey Time: ${(deliveryDetails.totalJourneyTime / 60).round()} mins'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(onPressed: () => declineDelivery(orderNo), child: const Text('Decline')),
                          ElevatedButton(onPressed: () => acceptDelivery(orderNo), child: const Text('Accept'))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ) : const SizedBox.shrink();
        }
      },
    );
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

  Future<void> _loadUserData() async {
    try {
      // Fetch user document from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_UID)
          .get();

      if (userSnapshot.exists) {
        // If user document exists, update the firstName state
        setState(() {
          name = userSnapshot['First Name'] + ' ' + userSnapshot['Last Name'];

        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<List?> distance(var destination, String mode, var origin) async{
    Uri uri = Uri.https(
        "maps.googleapis.com",
        '/maps/api/distancematrix/json',
        {
          "destinations": destination,
          "origins": origin.runtimeType == Position ? '${origin.latitude},${origin.longitude}' : origin,
          "mode": mode,
          "key": "AIzaSyDFcJ0SWLhnTZVktTPn8jB5nJ2hpuSfwNk"
        });

    String? response = await NetworkUtility.fetchUrl(uri);
    if (response != null) {
      final distanceMatrixResponse = DistanceMatrixResponse.fromJson(json.decode(response));
      return [distanceMatrixResponse.elements?.first.distance?.text,distanceMatrixResponse.elements?.first.duration?.value];
    }
    return null;

  }

  Future<void> originToStore() async{
    String tescoAddress = '14 Stocking Ave, Rathfarnham, Dublin';
    currentLocation = await determinePosition();
    List? values = await distance(tescoAddress, chosenMode, currentLocation!);
    distanceToStore = values?[0];
    totalJourneyTime = 0;
    totalJourneyTime += values?[1] as int;
  }

  void storeToDestinationDistance(String destination) async{
    String tescoAddress = '14 Stocking Ave, Rathfarnham, Dublin';
    List? values = await distance(tescoAddress, chosenMode, destination);
    storeToDestination = values?[0];
    totalJourneyTime += values?[1] as int;
  }

  Future<DeliveryDetails> getDistanceTime(String destination) async{
    String tescoAddress = '14 Stocking Ave, Rathfarnham, Dublin';
    currentLocation = await determinePosition();
    List? originToStore = await distance(tescoAddress, chosenMode, currentLocation!);
    List? storeToDestinationDistance = await distance(tescoAddress, chosenMode, destination);
    return DeliveryDetails(distanceToStore: originToStore?[0], storeToDestination: storeToDestinationDistance?[0], totalJourneyTime: (originToStore?[1] as int) + (storeToDestinationDistance?[1] as int));
  }
}


