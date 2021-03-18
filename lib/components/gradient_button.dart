import 'package:flutter/material.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/gradient_border.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  })   : _onPressed = onPressed,
        _child = child,
        super(key: key);

  final void Function() _onPressed;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    return GradientBorder(
      strokeWidth: 1,
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
