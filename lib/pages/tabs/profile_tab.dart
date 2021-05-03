import 'package:flutter/material.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/user_profile.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return const Center(child: Text('Not signed in'));
    }
    return UserProfile(userId: userId);
  }
}
