import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


enum ActivityTypes { orders, deliveries }

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  ActivityTypes? _character = ActivityTypes.orders;

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height * 0.1;
    return Scaffold(
      appBar: AppBar(
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
              )
            ],
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
                child: Text(
                    'Activity',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _character = ActivityTypes.orders;
                        });
                      },
                      child: Container(
                        height: containerHeight,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                'Orders',
                                style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.normal),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Radio<ActivityTypes>(
                                value: ActivityTypes.orders,
                                groupValue: _character,
                                onChanged: (ActivityTypes? value) {
                                  setState(() {
                                    _character = value;
                                  });
                                },
                                activeColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _character = ActivityTypes.deliveries;
                        });
                      },
                      child: Container(
                        height: containerHeight,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                'Deliveries',
                                style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.normal),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Radio<ActivityTypes>(
                                value: ActivityTypes.deliveries,
                                groupValue: _character,
                                onChanged: (ActivityTypes? value) {
                                  setState(() {
                                    _character = value;
                                  });
                                },
                                activeColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
              DefaultTabController(
                  length: 2,
                  child: Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius:  BorderRadius.circular(20),
                          ),
                          child: TabBar(
                              dividerColor: Colors.black12,
                              indicatorSize: TabBarIndicatorSize.tab,
                              unselectedLabelColor: Colors.black12,
                              indicatorWeight: 4.0,
                              labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.normal),
                              indicator: const UnderlineTabIndicator(
                                borderSide: BorderSide(
                                  width: 4.0, // Thickness of the underline
                                  color: Colors.black, // Color of the underline
                                ),
                                insets: EdgeInsets.symmetric(horizontal: 0.0), // Adjust this to fit the tab width
                              ),

                              labelColor: Colors.black,
                              tabs: const [
                                Tab(child: Text('Ongoing')),
                                Tab(child: Text('Completed')),
                              ]
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: TabBarView(
                            children: [
                              _buildListView(),
                              _buildListView()
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: ListView.builder(
        itemCount: 5, // Change this to the number of items you want in the list
        itemBuilder: (context, index) {
          return _buildListItem(context, index);
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '10 items',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300),
                  ),
                  Text(
                    '30th May, 2024 | 7:30pm',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Order #000001',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'View',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              )
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
