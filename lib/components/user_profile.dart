import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/components/follow_button.dart';
import 'package:spot/pages/follows_page.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/components/video_list.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/cubits/videos/videos_cubit.dart';
import 'package:spot/pages/edit_profile_page.dart';
import 'package:spot/repositories/repository.dart';

import 'profile_image.dart';

class UserProfile extends StatelessWidget {
  UserProfile({
    Key? key,
    required String userId,
  })  : _userId = userId,
        super(key: key);

  final String _userId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          const _Profile(),
          BlocProvider<VideosCubit>(
            create: (context) => VideosCubit(
                repository: RepositoryProvider.of<Repository>(context))
              ..loadFromUid(_userId),
            child: const _UserPosts(),
          ),
        ],
      ),
    );
  }
}

class _UserPosts extends StatelessWidget {
  const _UserPosts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
      builder: (context, state) {
        if (state is VideosInitial) {
          return preloader;
        } else if (state is VideosLoaded) {
          final videos = state.videos;
          return VideoList(videos: videos);
        } else if (state is VideosError) {
          return const Center(
            child: Text('Something went wrong. Please reopen the app. '),
          );
        }
        throw UnimplementedError();
      },
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
      if (state is ProfileLoading) {
        return preloader;
      } else if (state is ProfileNotFound) {
        return const Text('Profile not found');
      } else if (state is ProfileLoaded) {
        final profile = state.profile;

        /// Used to determine if the
        final isMyProfile =
            RepositoryProvider.of<Repository>(context).userId == profile.id;
        final verticalSpacing = const SizedBox(height: 24);

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 19,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileImage(
                size: 120,
                imageUrl: profile.imageUrl,
              ),
              verticalSpacing,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatsText(
                    onPressed: () {
                      Navigator.of(context).push(FollowsPage.route(
                        uid: profile.id,
                        isDisplayingFollowers: true,
                      ));
                    },
                    number: profile.followerCount,
                    label: 'Followers',
                  ),
                  _StatsText(
                    onPressed: () {
                      throw UnimplementedError();
                    },
                    number: profile.followingCount,
                    label: 'Following',
                  ),
                  _StatsText(
                    number: profile.likeCount,
                    label: 'Likes',
                  ),
                ],
              ),
              verticalSpacing,
              if (isMyProfile)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(EditProfilePage.route(isCreatingAccount: false));
                  },
                  icon: const Icon(
                    FeatherIcons.edit2,
                    size: 18,
                  ),
                  label: const Text('Edit Profile'),
                )
              else
                FollowButton(profile: profile),
              verticalSpacing,
              if (profile.description != null) ...[
                const SizedBox(height: 16),
                Text(profile.description!,
                    style: const TextStyle(fontSize: 16)),
                verticalSpacing,
              ],
            ],
          ),
        );
      } else if (state is ProfileError) {
        return const Center(
          child: Text('Error occured while loading profile'),
        );
      }
      throw UnimplementedError(
          'Unimplemented state in _Profile of user_profile.dart');
    });
  }
}

class _StatsText extends StatelessWidget {
  const _StatsText({
    Key? key,
    required this.label,
    required this.number,
    this.onPressed,
  }) : super(key: key);

  final String label;
  final int number;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Text(
              '$number',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
