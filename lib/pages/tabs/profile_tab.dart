import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/components/user_profile.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/constants.dart';

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
      )..loadMyProfile(),
      child: const MyUserProfile(),
    );
  }
}

class MyUserProfile extends StatelessWidget {
  const MyUserProfile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return UserProfile(userId: state.profile.id);
        } else if (state is ProfileError) {
          return const Center(
            child: Text('Error loading profile'),
          );
        } else {
          return preloader;
        }
      },
    );
  }
}
