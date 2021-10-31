import 'package:flutter/material.dart';

/// Displays a profile image of a user
class ProfileImage extends StatelessWidget {
  /// Displays a profile image of a user
  const ProfileImage({
    Key? key,
    double size = 50,
    String? imageUrl,
    void Function()? onPressed,
  })  : _size = size,
        _imageUrl = imageUrl,
        _onPressed = onPressed,
        super(key: key);

  final double _size;
  final String? _imageUrl;
  final void Function()? _onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: GestureDetector(
        onTap: _onPressed,
        child: ClipOval(
          child: _imageUrl == null
              ? Image.asset(
                  'assets/images/user.png',
                  fit: BoxFit.cover,
                )
              : Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
