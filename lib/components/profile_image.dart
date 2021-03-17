import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key? key,
    double? size,
  })  : _size = size ?? 50,
        super(key: key);

  final double _size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
        width: _size,
        height: _size,
        fit: BoxFit.cover,
      ),
    );
  }
}
