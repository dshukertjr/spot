import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/components/gradient_border.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    Key? key,
    required void Function() onPressed,
    required Widget child,
    double? strokeWidth,
    BoxDecoration? decoration,
  })  : _onPressed = onPressed,
        _child = child,
        _strokeWidth = strokeWidth ?? 1,
        _decoration = decoration,
        super(key: key);

  final void Function() _onPressed;
  final Widget _child;
  final double _strokeWidth;
  final BoxDecoration? _decoration;

  @override
  Widget build(BuildContext context) {
    return GradientBorder(
      strokeWidth: _strokeWidth,
      borderRadius: 4,
      gradient: redOrangeGradient,
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(max(4 - _strokeWidth, 0)),
        color: dialogBackgroundColor,
        child: Ink(
          decoration: _decoration,
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
      ),
    );
  }
}
