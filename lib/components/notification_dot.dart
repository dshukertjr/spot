import 'package:flutter/material.dart';
import 'package:spot/utils/constants.dart';

/// Simple dot to indicate that there is a notification
class NotificationDot extends StatelessWidget {
  /// Simple dot to indicate that there is a notification
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
