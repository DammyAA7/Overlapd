import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/utilities/toast.dart';
import '../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';


class EditAddress extends StatefulWidget {
  final Map<String, dynamic> addressDetails;

  const EditAddress({super.key, required this.addressDetails});
  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  late TextEditingController streetAddressController;
  late TextEditingController localityController;
  late TextEditingController countyController;
  late TextEditingController postalCodeController;
  bool isDefault = false;
  bool isModified = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();

  @override
  void initState() {
    super.initState();
    streetAddressController = TextEditingController(text: widget.addressDetails['Street Address']);
    localityController = TextEditingController(text: widget.addressDetails['Locality']);
    countyController = TextEditingController(text: widget.addressDetails['County']);
    postalCodeController = TextEditingController(text: widget.addressDetails['Postal Code']);
    isDefault = widget.addressDetails['Default'] ?? false;
  }

  void checkForModifications() {
    setState(() {
      isModified = streetAddressController.text != widget.addressDetails['Street Address'] ||
          localityController.text != widget.addressDetails['Locality'] ||
          countyController.text != widget.addressDetails['County'] ||
          postalCodeController.text != widget.addressDetails['Postal Code'] ||
          isDefault != (widget.addressDetails['Default'] ?? false);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Navigate to the home page with a fade transition
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title:  Text(
          'Edit Address',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Street Address"),
              addressInputBox('Street Address', true, false, streetAddressController.text, TextInputType.streetAddress, (newValue) {
                streetAddressController.text = newValue;
                checkForModifications();
              }),

              const Text("Locality"),
              addressInputBox('Locality', true, false, localityController.text, TextInputType.streetAddress, (newValue) {
                localityController.text = newValue;
                checkForModifications();
              }),

              const Text("County"),
              addressInputBox('County', true, false, countyController.text, TextInputType.streetAddress, (newValue) {
                countyController.text = newValue;
                checkForModifications();
              }),

              const Text("Postal code"),
              addressInputBox('Postal code', true, false, postalCodeController.text, TextInputType.streetAddress, (newValue) {
                postalCodeController.text = newValue;
                checkForModifications();
              }),
              CheckboxListTile(
                value: isDefault,
                onChanged: (bool? value) {
                  if(!widget.addressDetails['Default']){
                    setState(() {
                      isDefault = value ?? false;
                      checkForModifications();
                    });
                  } else{
                    showToast(text: 'Cannot remove as default');
                  }
                },
                title: Text('Set as Default', overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: solidButton(context, 'Update Address', () async{
          if (isModified) {
            // Fetch the current user document to get the address book
            final userDoc = await _auth.getAccountInfoGet(_UID);
            List<dynamic> addressBook = List.from(userDoc.data()?['Address Book'] ?? []);

            // Find the index of the address being edited
            int indexToUpdate = addressBook.indexWhere((address) => address['Full Address'] == widget.addressDetails['Full Address']);

            // Check if address exists in the address book
            if (indexToUpdate != -1) {
              // Update the address details
              addressBook[indexToUpdate] = {
                'Street Address': streetAddressController.text,
                'Locality': localityController.text,
                'County': countyController.text,
                'Postal Code': postalCodeController.text,
                'Default': isDefault,
                'Full Address': "${streetAddressController.text}, ${localityController.text}, ${postalCodeController.text}, ${countyController.text}",
                // Preserve other fields that are not being edited
              };

              // If setting this address as default, ensure to reset the Default flag for all others
              if (isDefault) {
                for (int i = 0; i < addressBook.length; i++) {
                  if (i != indexToUpdate) {
                    addressBook[i]['Default'] = false;
                  }
                }
              }

              // Update the document in Firestore with the modified address book
              await FirebaseFirestore.instance.collection('users').doc(_UID).update({
                'Address Book': addressBook,
                // Update lastAddressSelected if necessary
              });
            }
            // Optionally return true to indicate a successful update
            Navigator.pop(context);
          }
        },
          isModified && streetAddressController.text.isNotEmpty && localityController.text.isNotEmpty && countyController.text.isNotEmpty && postalCodeController.text.isNotEmpty,),
      ),
    );
  }
}
