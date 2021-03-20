import 'package:flutter/material.dart';

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
