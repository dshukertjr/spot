import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/cubits/videos/videos_cubit.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/repositories/repository.dart';

import 'profile_image.dart';

class UserProfile extends StatelessWidget {
  UserProfile({
    Key? key,
    required String userId,
  })   : _userId = userId,
        super(key: key);

  final String _userId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              databaseRepository: RepositoryProvider.of<Repository>(context),
            )..loadProfile(_userId),
            child: const _Profile(),
          ),
          BlocProvider<VideosCubit>(
            create: (context) => VideosCubit(
                databaseRepository: RepositoryProvider.of<Repository>(context))
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
          return Material(
            color: Colors.transparent,
            child: Wrap(
              children: List.generate(videos.length, (index) {
                final video = videos[index];
                return FractionallySizedBox(
                  widthFactor: 0.5,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Ink(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(video.thumbnailUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(ViewVideoPage.route(video.id));
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
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
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 31,
            horizontal: 19,
          ),
          child: Row(
            children: [
              const ProfileImage(size: 120),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(profile.name),
                    const SizedBox(height: 17),
                    if (profile.description != null) Text(profile.description!),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      throw UnimplementedError();
    });
  }
}
