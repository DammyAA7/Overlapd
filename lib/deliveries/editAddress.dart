import 'package:flutter/material.dart';

import '../utilities/widgets.dart';

class EditAddress extends StatefulWidget {
  final Map<String, dynamic> addressDetails;

  const EditAddress({super.key, required this.addressDetails});
  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Street Address"),
            addressInputBox('Street Address', true, false, widget.addressDetails['Street Address'] ?? "", TextInputType.streetAddress, (newValue) {
              setState(() {

              });
            },),

            const Text("Locality"),
            addressInputBox('Locality', true, false, widget.addressDetails['Locality'] ?? "", TextInputType.streetAddress, (newValue) {
              setState(() {

              });
            },),
            const Text("County"),
            addressInputBox('County', true, false, widget.addressDetails['County'] ?? "", TextInputType.streetAddress, (newValue) {
              setState(() {
              });
            },),
            const Text("Postal code"),
            addressInputBox('Postal code', true, false, widget.addressDetails['Postal Code'] ?? "", TextInputType.streetAddress, (newValue) {
              setState(() {

              });
            },),
            CheckboxListTile(
              value: widget.addressDetails['Default'],
              onChanged: (bool? value){
                setState(() {

                });
              },
              title: Text('Set as Default', overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.labelLarge,),
              //contentPadding: const EdgeInsets.only(right: 35),
              //materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: solidButton(context, 'Save Address', () {
          Navigator.pop(context);
        }, true),
      ),
    );
  }
}
