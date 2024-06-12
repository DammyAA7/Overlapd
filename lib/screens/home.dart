import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:overlapd/services/deliveryService/delivery_service.dart';
import 'package:overlapd/utilities/toast.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../services/storeService/groceryRange.dart';
import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../services/userAuthService/login.dart';
import '../utilities/deliveryDetailsUtilities.dart';
import '../utilities/networkUtilities.dart';
import '../utilities/widgets.dart';
import 'package:overlapd/utilities/homeUtilities.dart';
import 'package:overlapd/services/storeService/range.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  static const id = 'home_page';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}



class _HomeState extends State<Home> {
  late final TextEditingController inputController;
  static const LatLng sourceLocation = LatLng(53.27229,-6.32804);
  //static const LatLng destination = = LatLng(37.21, -122.64);
  StreamSubscription<Position>? positionStreamSubscription;
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
  int? pickerCode;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
    _buildList();
    inputController = TextEditingController(); // Initialize the TextEditingController
  }

  @override
  void dispose() {
    inputController.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
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
                  showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: const Text('Are you sure you want to sign out?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop('No'),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () async{
                              Navigator.pushReplacement(
                                dialogContext,
                                pageAnimationlr(const Login()),
                              );
                              _signOut();
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      )
                  );

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
                              _buildDeliveryStatus(),
                              _isVerifiedHasAccount()
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        ),
      ),
    );
  }

  Widget selectStoreTile(
      BuildContext context,
      String imageName,
      Map<String, Map<String,Map <String, Future<List<List>>>>> range,
      String storeName
      ) {
    return InkWell(
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

  void _signOut() async {
    try {
      await _auth.setLoggedOut();
      await FirebaseAuth.instance.signOut();
      showToast(text: "User logged out successfully");
      Navigator.pushNamed(context, '/login_page');
    } catch (e) {
      await _auth.setLoggedInAsUser();
      showToast(text: "An error occurred during sign-out");
      // Handle the exception or show an appropriate message to the user
    }
  }

  void acceptDelivery(String orderID, String paymentIntentId) async{
    try {
      //check if location services are enabled
      //currentPosition = await getCurrentLocation();
      //_startLocationMonitoring(orderID);
      // Retrieve the value of 'Placed by' from 'All Deliveries' collection

      _startLocationMonitoring(orderID);


      DocumentSnapshot deliverySnapshot = await FirebaseFirestore.instance
          .collection('All Deliveries')
          .doc('Open Deliveries')
          .collection('Order Info')
          .doc(orderID)
          .get();
      if (deliverySnapshot.exists) {
        String placedByUserID = deliverySnapshot['Placed by'];
        String address = deliverySnapshot['Delivery Address'];

        // Update 'accepted by' field in 'All Deliveries' collection
        await FirebaseFirestore.instance
            .collection('All Deliveries')
            .doc('Open Deliveries')
            .collection('Order Info')
            .doc(orderID)
            .update({'picked up by': _UID, 'status': 'Pick up assigned', 'arrivedInStore': false});

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
          }
          if(id.isNotEmpty && fieldExist){
            hasAccount = false;
            return solidButton(context, 'Login', () async{
              try{
                final loginResponse = await http.post(
                    Uri.parse('https://us-central1-overlapd-13268.cloudfunctions.net/StripeCreateLoginLink'),
                    body: {'account': id}
                );
                final jsonLoginResponse = jsonDecode(loginResponse.body);
                print(jsonLoginResponse);
                launchUrl(Uri.parse(jsonLoginResponse['url']), mode: LaunchMode.inAppBrowserView);
              } catch(e) {
                print(e);
              }
            }, true);
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
              String? accountEnabled = snapshot.data?['Stripe Account Disabled'];
              bool accountPayoutEnabled = snapshot.data!['Stripe Account Payout Enabled'];
              if (identityStatus == 'verified' && (accountId.isNotEmpty && accountEnabled == null && accountPayoutEnabled == true)) {
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the data is still loading, return a loading indicator
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            // If there is no data or the data is empty, display a message
            return const Text('No deliveries available');
          } else {
            bool hasAcceptedDelivery = snapshot.data!.docs.any((document) {
              Map<String, dynamic> data = document.data() as Map<String,
                  dynamic>;
              return data['picked up by'] == _UID && !data['delivered'] &&
                  !data['cancelled'];
            });

            bool hasPendingDelivery = snapshot.data!.docs.any((document) {
              Map<String, dynamic> data = document.data() as Map<String,
                  dynamic>;
              return data['Placed by'] == _UID && !data['delivered'] &&
                  !data['cancelled'];
            });

            bool hasAcceptedPendingDelivery = snapshot.data!.docs.any((
                document) {
              Map<String, dynamic> data = document.data() as Map<String,
                  dynamic>;
              return data['accepted by'] != _UID &&
                  data['accepted by'] != 'N/A';
            });
            if (hasAcceptedDelivery) {
              DocumentSnapshot activeOrderDocument = snapshot.data!.docs
                  .firstWhere(
                    (document) {
                  Map<String, dynamic> data = document.data() as Map<
                      String,
                      dynamic>;
                  return data['picked up by'] == _UID;
                },
              );
              String orderID = activeOrderDocument.id;
              String placedByUser = activeOrderDocument['Placed by'];
              String acceptedByUser = activeOrderDocument['picked up by'];
              String deliveryAddress = activeOrderDocument['Delivery Address'];
              List itemList = activeOrderDocument['Items for Delivery'];
              return Expanded(
                child: Column(
                  children: [
                    Expanded(child: activeDeliveryCard(
                        placedByUser, orderID, acceptedByUser, deliveryAddress,
                        itemList)),
                    pickerCode != null &&
                        activeOrderDocument['status'] != 'Order Handed Over'
                        ? Text('Give our employee this code: $pickerCode')
                        : const SizedBox.shrink(),
                    if (activeOrderDocument['status'] == 'Pick up assigned')
                      solidButton(context, 'Arrived at Store', () =>
                          checkIfArrived(orderID), true),
                    if (activeOrderDocument['arrivedInStore'] &&
                        activeOrderDocument['orderHandedOver'])
                      solidButton(context, 'Delivered', () =>
                          checkIfDelivered(orderID, activeOrderDocument), true),
                  ],
                ),
              );
            } else if (hasPendingDelivery) {
                return const Center(
                  child: Text('Deliveries Unavailable'),
                );
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
                    items: modeOfTransport.map((mode) =>
                        DropdownMenuItem<String>(
                          value: mode,
                          child: Text(mode, style: const TextStyle(
                              fontSize: 20)),
                        )
                    ).toList(),
                    value: chosenMode,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select store';
                      }
                      return null;
                    },
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          chosenMode = newValue;
                        });
                      }
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


  Widget _buildDeliveryStatus(){
    return StreamBuilder(
        stream: _service.getRequestedDeliveries(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the data is still loading, return a loading indicator
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // If there's an error, display an error message
            return Text('Error: ${snapshot.error}');
          } else {

            bool hasPendingDelivery = snapshot.data!.docs.any((document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return data['Placed by'] == _UID && !data['delivered'] &&
                  !data['cancelled'];
            });

            bool hasAcceptedPendingDelivery = snapshot.data!.docs.any((document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return data['accepted by'] != _UID && data['accepted by'] != 'N/A';
            });
            if(hasPendingDelivery){
              if(hasAcceptedPendingDelivery){
                DocumentSnapshot activeOrderDocument = snapshot.data!.docs.firstWhere(
                      (document) {
                    Map<String, dynamic> data = document.data() as Map<
                        String,
                        dynamic>;
                    return data['Placed by'] == _UID;
                  },
                );
                return Column(
                  children: [
                    solidButton(context, 'Track Location of Deliverer', () => trackDelivery(activeOrderDocument), activeOrderDocument['status'] == 'Order Handed Over'),
                  ],
                );
              } else{
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('Order Requested\nWe will notify you when the order has been accepted'),
                      solidButton(context, 'Cancel Delivery', _cancelDelivery, true)

                    ],
                  ),
                );
              }
            } else {
               return Column(
                 children: [
                   selectStoreTile(context, 'supervalu.png', range.supervaluGroceryRange, 'SuperValu'),
                   selectStoreTile(context, 'tesco.png', range.tescoGroceryRange, 'Tesco'),
                 ],
               );
            }
          }
        });
  }

  Widget _buildItem(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>;
    String orderNo = document.id;

    return FutureBuilder(
      future: getDistanceTime(data['Delivery Address Coordinates']),
      builder: (BuildContext context, AsyncSnapshot<DeliveryDetails?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.data == null) {
            return SizedBox.shrink();
        } else if (snapshot.hasError) {
          return Text('Error : ${snapshot.error}');
        } else {
          // Assuming snapshot.data now contains the DeliveryDetails object
          DeliveryDetails? details = snapshot.data;
          return data['Placed by'] != _UID && !data['declined By']?.contains(_UID) && !data['delivered'] ? Container(
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
                      Text('Distance to Store: ${details?.distanceToStore}'),
                      Text('Distance from Store to Destination: ${details?.storeToDestination}'),
                      Text('Total Journey Time: ${(details!.totalJourneyTime / 60).round()} mins'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(onPressed: () => declineDelivery(orderNo), child: const Text('Decline')),
                          ElevatedButton(onPressed: () => acceptDelivery(orderNo, data['payment id']), child: const Text('Accept'))
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
        .doc(latestPlacedDelivery).update({'cancelled' : true});
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

  Future<List?> calculateDistance({required String origin, required String destination, required String mode}) async {
    Uri uri = Uri.https(
      "maps.googleapis.com",
      '/maps/api/distancematrix/json',
      {
        "destinations": destination,
        "origins": origin,
        "mode": mode,
        "key": "AIzaSyDFcJ0SWLhnTZVktTPn8jB5nJ2hpuSfwNk"
      },
    );

    final response = await NetworkUtility.fetchUrl(uri);
    if (response != null) {
      final data = json.decode(response);
      final distanceMatrixResponse = DistanceMatrixResponse.fromJson(data);
      return [distanceMatrixResponse.elements?.first.distance?.text, distanceMatrixResponse.elements?.first.duration?.value];
    }
    return null;
  }

  Future<String> getPositionString() async {
    Position position = await determinePosition(); // Ensure this method is implemented correctly
    return '${position.latitude},${position.longitude}';
  }

  Future<DeliveryDetails?> getDistanceTime(GeoPoint destination) async {
    final currentLocation = await getPositionString();
    final originToStore = await calculateDistance(origin: currentLocation, destination: '14 Stocking Ave, Rathfarnham, Dublin', mode: chosenMode);
    final storeToDestination = await calculateDistance(origin: '14 Stocking Ave, Rathfarnham, Dublin', destination: '${destination.latitude}, ${destination.longitude}', mode: chosenMode);

    if (originToStore == null || storeToDestination == null) {
      // If distance or route cannot be determined for any segment, return null
      return null;
    }


    return DeliveryDetails(
      distanceToStore: originToStore[0],
      storeToDestination: storeToDestination[0],
      totalJourneyTime: (originToStore[1] ?? 0) + (storeToDestination[1] ?? 0),
    );
  }

  Future<String> getDelivererTime(String destination, String coordinates) async {
    final currentPositionToDestination = await calculateDistance(origin: coordinates, destination: destination, mode: chosenMode);
    return (currentPositionToDestination?[1]/ 60).round().toString();
  }

  void _startLocationMonitoring(String orderID) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Trigger location updates every 5 meters
    );

    positionStreamSubscription?.cancel(); // Cancel any existing subscription

    positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
        if (position != null) {
          // Update the Firestore document with the new location
          _updateDeliveryLocation(orderID, position);
        }
      },
    );

    positionStreamSubscription?.onError((error) {
      print('Error tracking location: $error');
    });
  }

  Future<void> _updateDeliveryLocation(String orderID, Position position) async {
    try {
      await FirebaseFirestore.instance
          .collection('All Deliveries')
          .doc('Open Deliveries')
          .collection('Order Info')
          .doc(orderID)
          .update({
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });
      print('Location updated to Firestore successfully');
    } catch (e) {
      print('Failed to update location: $e');
    }
  }

  double calculateLatLngDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742000 * asin(sqrt(a));
  }

  void checkIfArrived(String orderID) async{
    LatLng storeCoordinates = const LatLng(53.272981854167526, -6.31554308465661);
    currentPosition = await getCurrentLocation();
    double distanceAway = calculateLatLngDistance(storeCoordinates.latitude, storeCoordinates.longitude, currentPosition?.latitude, currentPosition?.longitude);
    if(distanceAway <= 200){
      pickerCode = Random().nextInt(90) + 10;
      showToast(text: 'Employee Notified and random code has code has been generated.');
      await FirebaseFirestore.instance
          .collection('All Deliveries')
          .doc('Open Deliveries')
          .collection('Order Info')
          .doc(orderID)
          .update({
        'arrivedInStore' : true,
        'picker code' : pickerCode
      });
    } else{
      showToast(text: 'You have not arrived');
    }

  }

  void trackDelivery(DocumentSnapshot activeOrderDocument){
    String destination = '${activeOrderDocument['Delivery Address Coordinates'].latitude}, ${activeOrderDocument['Delivery Address Coordinates'].longitude}';
    double latitude = activeOrderDocument['currentLocation']['latitude'];
    double longitude = activeOrderDocument['currentLocation']['longitude'];
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Track Location'),
          content: IntrinsicHeight(
            child: Column(
              children: [
                const Text('Open delivery location in Google Maps.'),
                FutureBuilder(
                    future: getDelivererTime(destination, '$latitude, $longitude'),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Updating Deliverer ETA...');
                      } else if (snapshot.hasError) {
                        return const Text('Error getting ETA');
                      } else {
                        String? time = snapshot.data;
                        return Text('Your deliverer is $time minutes away');
                      }
                    })

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Attempt to launch the Google Maps URL
                if (await canLaunchUrlString(googleMapsUrl)) {
                  await launchUrlString(googleMapsUrl);
                } else {
                  showToast(text: 'Could not open the map.');
                }
                Navigator.of(context).pop(); // Close the dialog after attempting to launch the URL
              },
              child: const Text('Open Map'),
            ),
          ],
        );
      },
    );
  }

  void checkIfDelivered(String orderID, DocumentSnapshot activeOrderDocument) async{
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_UID)
        .get();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirm the 2 digit code from deliveree'),
        content: TextField(
          controller: inputController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter the code here"),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async{
              if(inputController.text == activeOrderDocument['deliverer code'].toString()){
                showToast(text: 'Code Confirmed');
                inputController.clear();

                // Cancel location tracking
                positionStreamSubscription?.cancel();
                positionStreamSubscription = null; // Reset the subscription to null if you plan to reuse it.

                await FirebaseFirestore.instance
                    .collection('All Deliveries')
                    .doc('Open Deliveries')
                    .collection('Order Info')
                    .doc(orderID)
                    .update({
                  'status': 'Delivery Complete',
                  'delivered': true
                });

                DocumentSnapshot orderDataSnapshot = await FirebaseFirestore.instance
                    .collection('All Deliveries')
                    .doc('Open Deliveries')
                    .collection('Order Info')
                    .doc(orderID)
                    .get();

                // Get the data from the active order document
                final orderData = orderDataSnapshot.data();

                // Create a new document in the target collection
                await FirebaseFirestore.instance
                    .collection('All Deliveries')
                    .doc('Completed Deliveries')
                    .collection('Order Info')
                    .doc(orderID)
                    .set(orderData as Map<String, dynamic>);

                // Delete the document from the original collection
                await FirebaseFirestore.instance
                    .collection('All Deliveries')
                    .doc('Open Deliveries')
                    .collection('Order Info')
                    .doc(orderID)
                    .delete();

                try{
                  await http.post(Uri.parse(
                      'https://us-central1-overlapd-13268.cloudfunctions.net/StripeCreateTransfer'),
                      body: {
                        'destination':userSnapshot['Stripe Account Id'],
                        'source_transaction': activeOrderDocument['charge id']
                      });
                } catch(e){
                  print(e);
                }
                Navigator.of(dialogContext).pop();
                showToast(text: 'Delivery Complete');

              }
              else{
                showToast(text: 'Wrong Code');
              }

            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}


