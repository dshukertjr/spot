import 'package:flutter/material.dart';
import 'package:spot/pages/profile_page.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key? key,
    double? size,
    required String userId,
    String? imageUrl,
    bool? openProfileOnTap,
  })  : _size = size ?? 50,
        _userId = userId,
        _imageUrl = imageUrl,
        _openProfileOnTap = openProfileOnTap ?? false,
        super(key: key);

  final double _size;
  final String _userId;
  final String? _imageUrl;
  final bool _openProfileOnTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: _openProfileOnTap
            ? () {
                Navigator.of(context).push(ProfilePage.route(_userId));
              }
            : null,
        child: ClipOval(
          child: _imageUrl == null
              ? Image.asset(
                  'assets/images/user.png',
                  fit: BoxFit.cover,
                  width: _size,
                  height: _size,
                )
              : Image.network(
                  _imageUrl!,
                  width: _size,
                  height: _size,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
