import 'package:flutter/material.dart';

import '../utilities/widgets.dart';
import 'chat/chat.dart';
import 'home.dart';
class AcceptedDeliveryDetails extends StatefulWidget {
  final String placedByUserId;
  final String acceptedByUserName;
  static const id = 'accepteddeliverydetails_page';
  const AcceptedDeliveryDetails({super.key, required this.placedByUserId, required this.acceptedByUserName});

  @override
  State<AcceptedDeliveryDetails> createState() => _AcceptedDeliveryDetailsState();
}

class _AcceptedDeliveryDetailsState extends State<AcceptedDeliveryDetails> {
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
                  'Active Delivery',
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
                        pageAnimationFromBottomToTop(Chat(whatUser: false, receiverUserName: widget.acceptedByUserName, receiverUserId: widget.placedByUserId,)),
                      );
                    },
                    child: const Icon((Icons.chat))),
              const SizedBox(width: 15),
              const Icon((Icons.call)),
            ],)
          ],
        ),
      ),
    );
  }
}
