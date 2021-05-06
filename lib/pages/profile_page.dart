import 'package:flutter/material.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/components/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage(this._userId, {Key? key}) : super(key: key);

  static Route<void> route(String userId) {
    return MaterialPageRoute(builder: (_) => ProfilePage(userId));
  }

  final String _userId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(),
      body: UserProfile(userId: _userId),
    );
  }
}
