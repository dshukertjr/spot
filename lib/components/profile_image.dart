import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key? key,
    double? size,
    String? imageUrl,
    void Function()? onPressed,
  })  : _size = size ?? 50,
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
