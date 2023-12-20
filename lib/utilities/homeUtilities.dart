import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/acceptedDeliveryDetails.dart';
import 'package:overlapd/utilities/widgets.dart';

//when the user accepts a delivery, the currents unaccepted delivery requested are replaced with the card below. It gives the user a brief description of the order.
Widget activeDeliveryCard(String placedByUser, String orderID){
  return FutureBuilder<String>(
    future: getFirstName(placedByUser),
    builder: (context, firstNameSnapshot) {
      if (firstNameSnapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (firstNameSnapshot.hasError) {
        return Text('Error: ${firstNameSnapshot.error}');
      } else {
        String firstName = firstNameSnapshot.data ?? 'User';

        return GestureDetector(
          onTap: (){
            Navigator.pushReplacement(
              context,
              pageAnimationrl(const AcceptedDeliveryDetails()),
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


