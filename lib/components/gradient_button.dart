import 'package:flutter/material.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/gradient_border.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    Key? key,
    required void Function() onPressed,
    required Widget child,
    double? strokeWidth,
  })  : _onPressed = onPressed,
        _child = child,
        _strokeWidth = strokeWidth ?? 1,
        super(key: key);

  final void Function() _onPressed;
  final Widget _child;
  final double _strokeWidth;

  @override
  Widget build(BuildContext context) {
    return GradientBorder(
      strokeWidth: _strokeWidth,
      borderRadius: 4,
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          appRed,
          appYellow,
        ],
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(4),
        color: dialogBackgroundColor,
        child: InkWell(
          onTap: _onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            child: _child,
          ),
        ),
      ),
    );
  }
}
