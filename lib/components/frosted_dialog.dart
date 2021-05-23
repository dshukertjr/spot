import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedDialog extends StatefulWidget {
  const FrostedDialog({
    Key? key,
    required Widget child,
    bool hasBackdropShadow = false,
  })  : _child = child,
        _hasBackdropShadow = hasBackdropShadow,
        super(key: key);

  final Widget _child;
  final bool _hasBackdropShadow;

  @override
  _FrostedDialogState createState() => _FrostedDialogState();
}

class _FrostedDialogState extends State<FrostedDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _animationnController;
  late final CurvedAnimation _curve;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget._hasBackdropShadow
              ? const Color(0xFF000000).withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Center(
          child: AnimatedBuilder(
              animation: _curve,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 280,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000).withOpacity(0.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: widget._child,
                      ),
                    ),
                  ),
                ),
              ),
              builder: (context, child) {
                return Opacity(
                  opacity: _curve.value,
                  child: Transform.translate(
                    offset: Offset(0, 50 - 50 * _curve.value),
                    child: child,
                  ),
                );
              }),
        ),
      ),
    );
  }

  @override
  void initState() {
    _animationnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _curve = CurvedAnimation(
      parent: _animationnController,
      curve: Curves.easeOutCubic,
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationnController.dispose();
    super.dispose();
  }
}
