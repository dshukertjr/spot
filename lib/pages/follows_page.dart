import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/components/follow_button.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/constants.dart';

class FollowsPage extends StatelessWidget {
  const FollowsPage({
    Key? key,
    required this.isDisplayingFollowers,
  }) : super(key: key);

  final bool isDisplayingFollowers;

  static Route<void> route({
    required String uid,

    /// True if displaying followers
    /// False if display followings
    required bool isDisplayingFollowers,
  }) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => ProfileCubit(
          repository: RepositoryProvider.of<Repository>(context),
        )..loadFollowersOrFllowings(
            uid: uid,
            isLoadingFollowers: isDisplayingFollowers,
          ),
        child: FollowsPage(
          isDisplayingFollowers: isDisplayingFollowers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(isDisplayingFollowers ? 'Followers' : 'Following'),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is FollowerOrFollowingLoaded) {
            final profiles = state.followingOrFollower;
            return ListView.separated(
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return ListTile(
                    leading: ProfileImage(imageUrl: profile.imageUrl),
                    title: Text(profile.name),
                    trailing: FollowButton(profile: profile),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: profiles.length);
          } else if (state is ProfileError) {
            return const Center(
              child: Text('Error loading followers'),
            );
          }
          return preloader;
        },
      ),
    );
  }
}
