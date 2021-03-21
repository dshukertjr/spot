import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

part 'confirm_video_state.dart';

class ConfirmVideoCubit extends Cubit<ConfirmVideoState> {
  ConfirmVideoCubit() : super(ConfirmVideoInitial());

  late final VideoPlayerController _videoPlayerController;

  Future<void> initialize({required XFile videoFile}) async {
    _videoPlayerController = VideoPlayerController.file(File(videoFile.path));
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    emit(ConfirmVideoPlaying(videoPlayerController: _videoPlayerController));
  }
}
