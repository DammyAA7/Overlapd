import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utilities/widgets.dart';

class OrderTimeline extends StatefulWidget {
  const OrderTimeline({super.key});

  @override
  State<OrderTimeline> createState() => _OrderTimelineState();
}

class _OrderTimelineState extends State<OrderTimeline> {
  final String code = "2002"; // The 4-digit code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: MediaQuery.of(context).size.height * 0.25,
          title:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.arrow_back_outlined),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: const Text('Go back'),
                      )
                    ],
                  ),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.shopping_cart_outlined, color: Colors.black),
                      )
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('Your order is being completed',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300)
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text('Share this code with the person who delivers your order',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                  Wrap(
                    runAlignment: WrapAlignment.start,
                    spacing: 8.0, // Space between each container
                    children: List.generate(code.length, (index) {
                      return CodeContainer(text: code[index]);
                    }),
                  )
                ],
              )
            ],
          )
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 22),
        child: ListView(
            children: [
              statusTimelineTile(isFirst: true, isLast: false, isPast: true, eventCard: timelineTileText('Order Received', 'User accepted your delivery request', 'They are on their way to store')),
              statusTimelineTile(isFirst: false, isLast: false, isPast: false, eventCard: timelineTileText('Shopping in progress', 'Shopper has confirmed your order, and is shopping your items', '')),
              statusTimelineTile(isFirst: false, isLast: false, isPast: false, eventCard: timelineTileText('Shopping complete & Awaiting pick up', 'Your shopper has paid for the goods', 'Your delivery person will pick them up shortly')),
              statusTimelineTile(isFirst: false, isLast: false, isPast: false, eventCard: timelineTileText('Groceries picked up', 'Your delivery person has picked up your groceries and is on their way to you.', 'You can follow their progress by tracking them on the map')),
              statusTimelineTile(isFirst: false, isLast: true, isPast: false, eventCard: timelineTileText('Delivered', 'Your items have been delivered successfully', '')),

            ]
        ),
      ),
    );
  }
}

class CodeContainer extends StatelessWidget {
  final String text;

  const CodeContainer({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(text),
    );
  }
}
