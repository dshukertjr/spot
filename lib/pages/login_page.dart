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
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x26000000),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Sign in'),
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
