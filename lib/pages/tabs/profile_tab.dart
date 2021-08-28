import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/components/user_profile.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/repositories/repository.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = RepositoryProvider.of<Repository>(context).userId;
    if (userId == null) {
      return const Center(child: Text('Not signed in'));
    }
    return BlocProvider<ProfileCubit>(
      create: (context) => ProfileCubit(
        repository: RepositoryProvider.of<Repository>(context),
      )..loadProfile(userId),
      child: UserProfile(userId: userId),
    );
  }
}
