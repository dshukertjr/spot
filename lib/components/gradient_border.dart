import 'package:flutter/material.dart';

class GradientBorder extends StatelessWidget {
  /// Wraps the child widget with gradient border
  const GradientBorder({
    Key? key,
    required double borderRadius,
    required double strokeWidth,
    required Gradient gradient,
    required Widget child,
  })  : _borderRadius = borderRadius,
        _strokeWidth = strokeWidth,
        _gradient = gradient,
        _child = child,
        super(key: key);

  final double _borderRadius;
  final double _strokeWidth;
  final Gradient _gradient;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBorderPainter(
        strokeWidth: _strokeWidth,
        borderRadius: _borderRadius,
        gradient: _gradient,
      ),
      child: Padding(
        padding: EdgeInsets.all(_strokeWidth),
        child: _child,
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({
    required double strokeWidth,
    required double borderRadius,
    required Gradient gradient,
  })  : _strokeWidth = strokeWidth,
        _borderRadius = borderRadius,
        _gradient = gradient;

  final Paint _paint = Paint();
  final double _borderRadius;
  final double _strokeWidth;
  final Gradient _gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    final outerRect = Offset.zero & size;
    final outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(_borderRadius));

    // create inner rectangle smaller by strokeWidth
    final innerRect = Rect.fromLTWH(
        _strokeWidth, _strokeWidth, size.width - _strokeWidth * 2, size.height - _strokeWidth * 2);
    final innerRRect =
        RRect.fromRectAndRadius(innerRect, Radius.circular(_borderRadius - _strokeWidth));

    // apply gradient shader
    _paint.shader = _gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    final path1 = Path()..addRRect(outerRRect);
    final path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
