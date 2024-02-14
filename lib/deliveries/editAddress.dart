import 'package:flutter/material.dart';
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
                  setState(() {
                    isDefault = value ?? false;
                    checkForModifications();
                  });
                },
                title: Text('Set as Default', overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: solidButton(context, 'Update Address', () {
          Navigator.pop(context);
        },
          isModified && streetAddressController.text.isNotEmpty && localityController.text.isNotEmpty && countyController.text.isNotEmpty && postalCodeController.text.isNotEmpty,),
      ),
    );
  }
}
