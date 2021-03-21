import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/full_screen_video_player.dart';
import 'package:spot/cubits/confirm_video/confirm_video_cubit.dart';

import '../components/app_scaffold.dart';

class ConfirmRecordingPage extends StatelessWidget {
  static Route<void> route({required XFile videoFile}) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ConfirmVideoCubit>(
        create: (context) =>
            ConfirmVideoCubit()..initialize(videoFile: videoFile),
        child: ConfirmRecordingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<ConfirmVideoCubit, ConfirmVideoState>(
        builder: (context, state) {
          if (state is ConfirmVideoInitial) {
            return preloader;
          } else if (state is ConfirmVideoPlaying) {
            return FullScreenVideoPlayer(
              videoPlayerController: state.videoPlayerController,
            );
          }
          throw UnimplementedError('Confirm Recording Page State not caught');
        },
      ),
    );
  }
}
