import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/acceptedDeliveryDetails.dart';
import 'package:overlapd/utilities/widgets.dart';
import '../screens/requestedDeliveryStatus.dart';

//when the user accepts a delivery, the currents unaccepted delivery requested are replaced with the card below. It gives the user a brief description of the order.
Widget activeDeliveryCard(String placedByUser, String orderID, String acceptedByUser){
  return FutureBuilder(
    future: Future.wait([getFirstName(placedByUser), getFirstName(acceptedByUser)]),
    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        String firstName = snapshot.data?[0];
        String acceptedUserFirstName = snapshot.data?[1];
        return GestureDetector(
          onTap: (){
            Navigator.pushReplacement(
              context,
              pageAnimationrl(AcceptedDeliveryDetails(placedByUserId: placedByUser, acceptedByUserName: acceptedUserFirstName)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 140,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xFF21D19F).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order No: $orderID', style: const TextStyle(fontSize: 20)),
                            Text('You\'ll be grocery shopping for $firstName', style: const TextStyle(fontSize: 20)),
                            const Text('You will earn €6.99 from this delivery', style: TextStyle(fontSize: 20))
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_outlined)
                      ],
                    ),
                  ),
                ),
                const Expanded(flex: 5, child: SizedBox.shrink())
              ],
            ),
          ),
        );
      }
    },
  );
}

//gets the first name of the user from the users collection using their unique ID
Future<String> getFirstName(String userId) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId).get();
  return userSnapshot['First Name'];
}


Widget activeDeliveryStatusCard(String acceptedByUser, String orderID, String placedByUser){
  return FutureBuilder(
    future: Future.wait([getFirstName(acceptedByUser), getFirstName(placedByUser)]),
    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        String firstName = snapshot.data?[0];
        String placedByFirstName = snapshot.data?[1];
        print(firstName);
        print(placedByFirstName);
        return GestureDetector(
          onTap: (){
            Navigator.pushReplacement(
              context,
              pageAnimationrl(RequestedDeliveryStatus(acceptedByUserId: acceptedByUser, placedByUserName: placedByFirstName)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3.0),
                  height: 140,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xFF21D19F).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order No: $orderID', style: const TextStyle(fontSize: 20)),
                          Text('$firstName will shop and deliver your items',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios_outlined)
                    ],
                  ),
                ),
                SizedBox.shrink()
              ],
            ),
          ),
        );
      }
    },
  );
}


