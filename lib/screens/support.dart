import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/utilities/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';
import '../utilities/widgets.dart';
import 'home/home.dart';

class Support extends StatefulWidget {
  static const id = 'support_page';
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final InputBoxController title = InputBoxController();
  final InputBoxController body = InputBoxController();

  bool _areFieldsValid() {
    return body.getText().isNotEmpty && title.getText().isNotEmpty;
  }

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                'Support',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pageText(context, 'Title'),
              supportLetterInputBox('Enter Subject', true, false, title),
              pageText(context, 'Body'),
              multilineLetterInputBox(
                  'Enter complaint, suggestion or feedback', true, false, body),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: solidButton(context, 'Submit', () {
          submitFeedback();
        }, _areFieldsValid()),
      ),
    );
  }

  void submitFeedback() async {
    // Create a map with the data you want to submit
    Map<String, dynamic> feedbackData = {
      'title': title.getText(),
      'body': body.getText(),
      'timestamp': FieldValue
          .serverTimestamp(), // This will add the current timestamp according to Firestore's server
      'userId': _auth
          .getUsername(), // Assuming you want to track which user submitted the feedback
    };

    try {
      // Add the feedback to the 'support' collection
      await FirebaseFirestore.instance.collection('support').add(feedbackData);

      // Show a success message
      showToast(text: 'Your message has been sent successfully.');
      // Optionally clear the fields if the submission was successful
      setState(() {
        body.clear();
        title.clear();
      });
    } catch (e) {
      // If there's any error, show an error message
      showToast(text: 'Failed to send message: $e');
      print('Error submitting feedback: $e');
    }
  }
}
