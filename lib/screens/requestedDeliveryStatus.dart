import 'package:flutter/material.dart';
import 'package:overlapd/screens/chat/chat.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../utilities/widgets.dart';
import 'home.dart';

class RequestedDeliveryStatus extends StatefulWidget {
  static const id = 'requesteddeliverystatus_page';
  const RequestedDeliveryStatus({super.key});

  @override
  State<RequestedDeliveryStatus> createState() => _RequestedDeliveryStatusState();
}

class _RequestedDeliveryStatusState extends State<RequestedDeliveryStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    // Navigate to the home page with a fade transition
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Delivery Status',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ],),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    //Navigator.pushReplacement(context,pageAnimationFromBottomToTop(Chat(whatUser: true, receiverUserId: widget.acceptedByUserId, receiverUserName: widget.placedByUserName,)),);
                  },
                    child: const Icon((Icons.chat))),
                const SizedBox(width: 15),
                const Icon((Icons.call)),
              ],)
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: solidButton(context, 'Upload Receipt', () => null, true),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: solidButton(context, 'Confirm Delivery', () => null, false),
            ),
          ],
        )
      ),
    );
  }

}



