import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../utilities/widgets.dart';
import '../cart/provider/cart_provider.dart';
import '../category/provider/shop_by_category_provider.dart';

class OrderTimeline extends StatefulWidget {
  const OrderTimeline({super.key});

  @override
  State<OrderTimeline> createState() => _OrderTimelineState();
}

class _OrderTimelineState extends State<OrderTimeline> {
  final String code = "2002"; // The 4-digit code
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShopByCategoryProvider(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: MediaQuery.of(context).size.height * 0.10,
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
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('Go back'),
                        )
                      ],
                    ),
                    IconButton(
                      icon: Stack(
                        children: [
                           Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Icon(Icons.shopping_cart_outlined, color: Colors.black),
                              )
                          ),
                          Positioned(
                            left: 25,
                            child: Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Consumer<CartProvider>(
                                    builder: (context, provider, child) {
                                      return Text(
                                        provider.cart[0].products.length.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    }
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            )
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your order is being completed',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300)
                    ),
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
                ),
              ),
              Expanded(
                child: ListView(
                    children: [
                      statusTimelineTile(isFirst: true, isLast: false, isPast: true, eventCard: timelineTileText(context, 'Order Received', 'User accepted your delivery request', 'They are on their way to store', null)),
                      statusTimelineTile(isFirst: false, isLast: false, isPast: true, eventCard: timelineTileText(context, 'Shopping in progress', 'Shopper has confirmed your order, and is shopping your items', '', null)),
                      statusTimelineTile(isFirst: false, isLast: false, isPast: true, eventCard: timelineTileText(context, 'Shopping complete & Awaiting pick up', 'Your shopper has paid for the goods', 'Your delivery person will pick them up shortly', null)),
                      statusTimelineTile(isFirst: false, isLast: false, isPast: true, eventCard: timelineTileText(context, 'Groceries picked up', 'Your delivery person has picked up your groceries and is on their way to you.', 'You can follow their progress by tracking them on the map', true)),
                      statusTimelineTile(isFirst: false, isLast: true, isPast: false, eventCard: timelineTileText(context, 'Delivered', 'Your items have been delivered successfully', '', null)),

                    ]
                ),
              ),
            ],
          ),
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
