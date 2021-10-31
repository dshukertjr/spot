import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/components/video_list.dart';
import 'package:spot/cubits/videos/videos_cubit.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/constants.dart';

class LikesPage extends StatelessWidget {
  const LikesPage({Key? key}) : super(key: key);

  static Route<void> route(String uid) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => VideosCubit(
          repository: RepositoryProvider.of<Repository>(context),
        )..loadLikedPosts(uid),
        child: const LikesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Likes'),
      ),
      body: BlocBuilder<VideosCubit, VideosState>(
        builder: (context, state) {
          if (state is VideosLoaded) {
            final videos = state.videos;
            return SingleChildScrollView(
              padding: MediaQuery.of(context).padding,
              child: VideoGrid(videos: videos),
            );
          }
          return preloader;
        },
      ),
    );
  }
}
