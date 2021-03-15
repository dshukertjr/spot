import 'package:flutter/material.dart';

class SearchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 30,
            ),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Search away my friend',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
