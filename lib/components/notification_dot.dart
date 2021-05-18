import 'package:flutter/material.dart';
import 'package:spot/app/constants.dart';

class NotificationDot extends StatelessWidget {
  const NotificationDot({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 6,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: redOrangeGradient,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
