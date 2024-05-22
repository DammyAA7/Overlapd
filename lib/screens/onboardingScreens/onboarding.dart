import 'package:flutter/material.dart';
import 'package:overlapd/utilities/authUtilities/enterPhoneNumber.dart';
import 'package:overlapd/utilities/customButton.dart';
import 'package:overlapd/utilities/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  @override
  Widget build(BuildContext context) {
    final double phoneHeight = MediaQuery.of(context).size.height;
    final pages = List.generate(
        4,
            (index) =>
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: phoneHeight * 0.45,
                    child: const Icon(
                      Icons.image,
                      size: 85,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0,10.0, 0,0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          'This paragraph describes a USP',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          'Lorem ipsum dolor sit amet consectetur',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              SizedBox(
                height: phoneHeight * 0.80,
                child: PageView.builder(
                  controller: controller,
                  // itemCount: pages.length,
                  itemBuilder: (_, index) {
                    return pages[index % pages.length];
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SmoothPageIndicator(
                  controller: controller,
                  count: pages.length,
                  effect: const WormEffect(
                    activeDotColor: Colors.black,
                    dotHeight: 10,
                    dotWidth: 10,
                    type: WormType.thinUnderground,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                        context,
                        'Log in',
                        () {
                          Navigator.of(context).pushReplacement(pageAnimationrl(
                              const EnterPhoneNumber(type: 'Log in',)
                          ));
                        },
                        MediaQuery.of(context).size.width * 0.45,
                        Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.normal),
                        Colors.grey
                    ),
                    Button(
                      context,
                      'Sign up',
                       () {
                         Navigator.of(context).pushReplacement(pageAnimationrl(
                             const EnterPhoneNumber(type: 'Sign up')
                         ));
                       },
                      MediaQuery.of(context).size.width * 0.45,
                      Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                      Colors.black
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
