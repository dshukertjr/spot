import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 31),
        Row(
          children: [
            Image.network(
                'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all'),
            const SizedBox(width: 18),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('@Newyorker'),
                const SizedBox(height: 17),
                const Text(''),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
