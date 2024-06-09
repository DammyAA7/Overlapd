import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isUserLoggedInAsUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedInInAsUser') ?? false;
}

