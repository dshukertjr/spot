import 'dart:ui';

import 'package:flutter/material.dart';

import '../components/app_scaffold.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              top: -53,
              right: -47,
              child: Image.asset(
                'assets/images/purple-fog.png',
                height: 228,
              )),
          Positioned(
            top: 201,
            left: 0,
            child: Image.asset(
              'assets/images/blue-ellipse.png',
              height: 168,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 37,
            child: Image.asset('assets/images/blue-blob.png'),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 46,
            child: Image.asset('assets/images/yellow-blob.png'),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/red-blob.png'),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 280,
                  ),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0x26000000),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sign in',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 24.5),
                          _LoginButton(
                            icon: Image.asset(
                              'assets/images/google.png',
                              width: 16,
                              height: 16,
                            ),
                            label: 'Sign in with Google',
                            onPressed: () {},
                          ),
                          const SizedBox(height: 24.5),
                          _LoginButton(
                            icon: Image.asset(
                              'assets/images/apple.png',
                              width: 16,
                              height: 16,
                            ),
                            label: 'Sign in with Apple',
                            onPressed: () {},
                          ),
                          const SizedBox(height: 24.5),
                          const Text(
                            'By signing in, you agree to the Terms of Service and Privacy Policy',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton(
      {Key? key,
      required void Function() onPressed,
      required String label,
      required Widget icon})
      : _onPressed = onPressed,
        _label = label,
        _icon = icon,
        super(key: key);

  final void Function() _onPressed;
  final String _label;
  final Widget _icon;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBorderPainter(
        strokeWidth: 1,
        radius: 4,
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFD83B63),
            Color(0xFFDFC14F),
          ],
        ),
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFF000000).withOpacity(0.2),
        child: InkWell(
          onTap: _onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            child: Row(
              children: [
                _icon,
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({
    required double strokeWidth,
    required double radius,
    required Gradient gradient,
  })   : _strokeWidth = strokeWidth,
        _radius = radius,
        _gradient = gradient;

  final Paint _paint = Paint();
  final double _radius;
  final double _strokeWidth;
  final Gradient _gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    final outerRect = Offset.zero & size;
    final outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(_radius));

    // create inner rectangle smaller by strokeWidth
    final innerRect = Rect.fromLTWH(_strokeWidth, _strokeWidth,
        size.width - _strokeWidth * 2, size.height - _strokeWidth * 2);
    final innerRRect = RRect.fromRectAndRadius(
        innerRect, Radius.circular(_radius - _strokeWidth));

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
