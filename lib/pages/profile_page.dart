import 'package:flutter/material.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/components/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage(this.userId, {Key? key}) : super(key: key);

  static Route<void> route(String userId) {
    return MaterialPageRoute(builder: (_) => ProfilePage(userId));
  }

  final String userId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(),
      body: UserProfile(userId: userId),
    );
  }
}
