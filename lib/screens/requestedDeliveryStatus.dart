import 'package:flutter/material.dart';
import 'package:overlapd/screens/chat/chat.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../utilities/widgets.dart';
import 'home.dart';

class RequestedDeliveryStatus extends StatefulWidget {
  final String acceptedByUserId;
  final String placedByUserName;
  static const id = 'requesteddeliverystatus_page';
  const RequestedDeliveryStatus({super.key, required this.acceptedByUserId, required this.placedByUserName});

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
                    Navigator.pushReplacement(
                      context,
                      pageAnimationlr(const Home()),
                    );
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
                    Navigator.pushReplacement(
                      context,
                      pageAnimationFromBottomToTop(Chat(whatUser: true, receiverUserId: widget.acceptedByUserId, receiverUserName: widget.placedByUserName,)),
                    );
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
              child: solidButton(context, 'View Receipt', () => null, false),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: solidButton(context, 'Confirm Delivery', () => null, false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 22),
                child: ListView(
                  children: [
                    statusTimelineTile(
                        isFirst: true,
                        isLast: false,
                        isPast: true,
                        eventCard: timelineTileText('Delivery Accepted', 'User accepted your delivery request', 'They are on their way to store')),
                    statusTimelineTile(isFirst: false, isLast: false, isPast: true, eventCard: timelineTileText('Shopping in porgress', 'Keep in contact with user', 'Confirm they\'ve purchased your desired item')),
                    statusTimelineTile(isFirst: false, isLast: false, isPast: true, eventCard: timelineTileText('Shopping Complete', 'User on their way to you', 'Confirm the items on the receipt')),
                    statusTimelineTile(isFirst: false, isLast: true, isPast: true, eventCard: timelineTileText('Delivered', 'Your items have been delivered succesfully', 'Rate your experience with user')),

                  ]
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget statusTimelineTile({
    required bool isFirst,
    required bool isLast,
    required bool isPast,
    required eventCard
  }){
    return SizedBox(
      height: 180,

      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        beforeLineStyle: LineStyle(
          color: isPast ? const Color(0xFF21D19F) : Colors.white
        ),
        indicatorStyle: IndicatorStyle(
          width: 35,
          color: isPast ? const Color(0xFF21D19F) : Colors.white,
          iconStyle: IconStyle(
            iconData: isPast ? Icons.done : Icons.close,
            color: Colors.white
          )
        ),
        endChild: EventCard(eventCard),
      ),
    );
  }

  Widget EventCard(Widget child){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 250,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1
          ),
        ),
        child: child,
      ),
    );
  }

  Widget timelineTileText(String header, String first, String second){
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: const TextStyle(
            fontWeight: FontWeight.bold
          )
        ),
        Text(first,
            overflow: TextOverflow.visible,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 18,
          )
        ),
        Text(second,
            overflow: TextOverflow.visible,
            maxLines: 2,
            style: const TextStyle(
                fontSize: 18
            )
        )
      ],
    );
  }
}



