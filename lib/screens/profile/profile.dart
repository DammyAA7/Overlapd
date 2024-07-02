import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:overlapd/screens/profile/profileDetails.dart';
import 'package:overlapd/screens/testScreen.dart';
import '../../models/userModel.dart';
import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';

class Profile extends StatefulWidget {
  static const id = 'settings_page';
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();

}

class _ProfileState extends State<Profile> {
  bool isModified = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  UserModel? _userModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _openHiveBox();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openHiveBox() async {
    await Hive.openBox<UserModel>('userBox');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final box = Hive.box<UserModel>('userBox');
    _userModel = box.get(_UID);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    String fullName = _userModel != null ? '${_userModel!.firstName} ${_userModel!.lastName}' : 'N/A';
    String initials = _userModel != null ? '${_userModel!.firstName[0]}${_userModel!.lastName[0]}' : 'NA';

    return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                children:[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey, // Customize as needed
                    child: Text(
                      initials,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(fullName),
                  Expanded(child: _buildListView())
                ]
            ),
          ),
        )
    );
  }

  Widget _buildListView() {
    final titles = ['Profile details', 'Addresses', 'Earnings', 'Referrals', 'Reward cards'];
    final routes = [
      const ProfileDetails(),  // Add your actual destination pages here
      TestScreen(),
      TestScreen(),
      TestScreen(),
      TestScreen(),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: ListView.builder(
        itemCount: 5, // Change this to the number of items you want in the list
        itemBuilder: (context, index) {
          return _buildListItem(context, index, titles[index], routes[index]);
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index, String title, Widget route) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => route),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios_outlined)
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Divider(),
            )
          ],
        ),
      ),
    );
  }

}
