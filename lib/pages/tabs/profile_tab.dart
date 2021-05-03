import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/components/user_profile.dart';
import 'package:spot/repositories/repository.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = RepositoryProvider.of<Repository>(context).supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return const Center(child: Text('Not signed in'));
    }
    return UserProfile(userId: userId);
  }
}
