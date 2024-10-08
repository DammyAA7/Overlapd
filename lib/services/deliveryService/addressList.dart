import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/services/deliveryService/addDeliveryAddress.dart';
import 'package:overlapd/services/deliveryService/editAddress.dart';
import 'package:overlapd/utilities/toast.dart';

import '../userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../../utilities/widgets.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key});

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Addresses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: hasAddressStored(),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: solidButton(context, 'Add Address', () {
          Navigator.push(
            context,
            pageAnimationrl(const AddDeliveryAddress()),
          );
        }, true),
      ),
    );
  }

  Widget hasAddressStored() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_UID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Text('No Addresses Stored');
        } else {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data.containsKey('Address Book') && data['Address Book'] is List) {
            final List<dynamic> addressBook = data['Address Book'];
            if (addressBook.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 70),
                shrinkWrap: true,
                itemCount: addressBook.length,
                itemBuilder: (context, index) {
                  final address = addressBook[index] as Map<String, dynamic>?;
                  return InkWell(
                    onTap: () => selectAddress(address!),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: IntrinsicHeight(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      address?['Full Address'] ?? 'No address',
                                      maxLines: 4,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, bottom: 5.0, right: 5.0, left: 2.0),
                                    child: GestureDetector(
                                      child: const Icon(Icons.edit),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          pageAnimationrl(EditAddress(addressDetails: address)),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: GestureDetector(
                                      child: const Icon(Icons.delete_outline),
                                      onTap: () {
                                        final bool isDefaultAddress = address?['Default'] == true;
                                        if (isDefaultAddress) {
                                          showToast(text: 'Default address cannot be deleted.');
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              title: const Text(
                                                  'Are you sure you want to delete this address'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, 'No'),
                                                  child: const Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    List<dynamic> updatedAddressBook =
                                                    List.from(addressBook)..removeAt(index);

                                                    await FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(_UID)
                                                        .update({'Address Book': updatedAddressBook});

                                                    final userDoc = await _auth.getAccountInfoGet(_UID);
                                                    final userData = userDoc.data();
                                                    if (userData != null &&
                                                        userData['lastAddressSelected'] != null &&
                                                        userData['lastAddressSelected']
                                                        ['Full Address'] ==
                                                            address?['Full Address']) {
                                                      await FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(_UID)
                                                          .update({'lastAddressSelected': FieldValue.delete()});
                                                    }
                                                    Navigator.pop(context, 'Yes');
                                                    showToast(text: 'Address deleted successfully');
                                                  },
                                                  child: const Text('Yes'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              address?['Default']
                                  ? Text(
                                'Default Address',
                                style: Theme.of(context).textTheme.labelMedium,
                              )
                                  : const SizedBox.shrink(),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Text('No Addresses Stored');
            }
          } else {
            return const Text('No Addresses Stored');
          }
        }
      },
    );
  }

  void selectAddress(Map<String, dynamic> selectedAddress) async {
    await FirebaseFirestore.instance.collection('users').doc(_UID).update({
      'lastAddressSelected': selectedAddress,
    });
    Navigator.pop(context);
  }
}
