import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const persistantSessionKey = 'supabase_session';

const localStorage = FlutterSecureStorage();

const appRed = Color(0xFFD73763);
const appOrange = Color(0xFFF6935C);
const appYellow = Color(0xFFDFC14F);
const appBlue = Color(0xFF3790E3);
const appLightBlue = Color(0xFF43CBE9);
const appPurple = Color(0xFF8F42A0);

const buttonBackgroundColor = Color(0x33000000);
const dialogBackgroundColor = Color(0x26000000);

const redOrangeGradient = LinearGradient(
  colors: [
    appRed,
    appOrange,
  ],
);

const blueGradient = LinearGradient(colors: [
  appBlue,
  appLightBlue,
]);

const preloader = Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(appRed),
  ),
);

final String Function(DateTime) howLongAgo = (DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);
  if (difference < const Duration(minutes: 1)) {
    return 'now';
  } else if (difference < const Duration(hours: 1)) {
    return '${difference.inMinutes}m';
  } else if (difference < const Duration(days: 1)) {
    return '${difference.inHours}h';
  } else if (difference < const Duration(days: 30)) {
    return '${difference.inDays}';
  } else if (now.year == time.year) {
    return '${time.month}-${time.day}';
  } else {
    return '${time.year}-${time.month}-${time.day}';
  }
};

extension ShowSnackBar on BuildContext {
  void showSnackbar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }

  void showErrorSnackbar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(
        text,
        style: const TextStyle(color: Color(0xFFFFFFFF)),
      ),
      backgroundColor: appRed,
    ));
  }
}
