import 'package:flutter/material.dart';

/// Size of each markers on a map
const defaultMarkerSize = 75.0;

/// Width of the border of markers on maps
const borderWidth = 5.0;

/// Red color used in the app.
const appRed = Color(0xFFD73763);

/// Orange color used in the app.
const appOrange = Color(0xFFF6935C);

/// Yellow color used in the app.
const appYellow = Color(0xFFDFC14F);

/// Blue color used in the app.
const appBlue = Color(0xFF3790E3);

/// Light blue color used in the app.
const appLightBlue = Color(0xFF43CBE9);

/// Purple color used in the app.
const appPurple = Color(0xFF8F42A0);

/// Background color of a button.
const buttonBackgroundColor = Color(0x33000000);

/// Background color of a frosted dialog.
const dialogBackgroundColor = Color(0x26000000);

/// Gradient of red and orange.
const redOrangeGradient = LinearGradient(
  colors: [
    appRed,
    appOrange,
  ],
);

/// Gradient of blue and light blue.
const blueGradient = LinearGradient(colors: [
  appBlue,
  appLightBlue,
]);

/// Maximum duration of video that users can post.
/// Anything beyond this duration will be cropped out.
const maxVideoDuration = Duration(seconds: 30);

/// Preloader to be shownn when loading something.
const preloader = Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(appRed),
  ),
);

/// Utility method to convert timestamp to human readable text.
final String Function(DateTime, {DateTime? seed}) howLongAgo = (
  DateTime time, {
  DateTime? seed,
}) {
  final now = seed ?? DateTime.now();
  final difference = now.difference(time);
  if (difference < const Duration(minutes: 1)) {
    return 'now';
  } else if (difference < const Duration(hours: 1)) {
    return '${difference.inMinutes}m';
  } else if (difference < const Duration(days: 1)) {
    return '${difference.inHours}h';
  } else if (difference < const Duration(days: 30)) {
    return '${difference.inDays}d';
  } else if (now.year == time.year) {
    return '${time.month < 10 ? '0' : ''}${time.month}-'
        '${time.day < 10 ? '0' : ''}${time.day}';
  } else {
    return '${time.year}-${time.month < 10 ? '0' : ''}'
        '${time.month}-${time.day < 10 ? '0' : ''}${time.day}';
  }
};

/// Extention method to easily display snack bar.
extension ShowSnackBar on BuildContext {
  /// Extention method to easily display snack bar.
  void showSnackbar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Extention method to easily display error snack bar.
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

/// Google map's theme for this app.
const mapTheme =
// ignore: lines_longer_than_80_chars
    '[{"elementType":"geometry","stylers":[{"color":"#202c3e"}]},{"elementType":"labels","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#ffffff"},{"saturation":10},{"weight":1.5}]},{"elementType":"labels.text.stroke","stylers":[{"visibility":"off"},{"weight":1}]},{"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"visibility":"on"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.neighborhood","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#273556"},{"saturation":10}]},{"featureType":"landscape.man_made","elementType":"labels.text","stylers":[{"color":"#ffffff"},{"visibility":"off"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"saturation":20}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"saturation":-20},{"lightness":20}]},{"featureType":"road","elementType":"geometry","stylers":[{"saturation":-30},{"lightness":10}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#3f499d"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"saturation":25},{"lightness":25},{"weight":"0.01"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#ff0000"}]},{"featureType":"water","stylers":[{"lightness":-20}]}]';
