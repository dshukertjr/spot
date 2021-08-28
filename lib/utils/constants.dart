import 'package:flutter/material.dart';

/// Size of each markers on a map
const markerSize = 100.0;

/// Width of the border of markers on maps
const borderWidth = 6.0;

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

const maxVideoDuration = Duration(seconds: 30);

const preloader = Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(appRed),
  ),
);

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
    return '${time.month < 10 ? '0' : ''}${time.month}-${time.day < 10 ? '0' : ''}${time.day}';
  } else {
    return '${time.year}-${time.month < 10 ? '0' : ''}${time.month}-${time.day < 10 ? '0' : ''}${time.day}';
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

const mapTheme =
    '[{"elementType":"geometry","stylers":[{"color":"#202c3e"}]},{"elementType":"labels","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#ffffff"},{"saturation":10},{"weight":1.5}]},{"elementType":"labels.text.stroke","stylers":[{"visibility":"off"},{"weight":1}]},{"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"visibility":"on"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.neighborhood","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#273556"},{"saturation":10}]},{"featureType":"landscape.man_made","elementType":"labels.text","stylers":[{"color":"#ffffff"},{"visibility":"off"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"saturation":20}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"saturation":-20},{"lightness":20}]},{"featureType":"road","elementType":"geometry","stylers":[{"saturation":-30},{"lightness":10}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#3f499d"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"saturation":25},{"lightness":25},{"weight":"0.01"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#ff0000"}]},{"featureType":"water","stylers":[{"lightness":-20}]}]';
