import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/repositories/repository.dart';
import 'package:video_player/video_player.dart';

import '../../models/video.dart';

part 'video_state.dart';

/// Takes care of actions done on single video
/// like viewing liking, blocking and such
class VideoCubit extends Cubit<VideoState> {
  VideoCubit({required Repository repository})
      : _repository = repository,
        super(VideoInitial());

  final Repository _repository;

  late final String _videoId;
  late final VideoDetail _video;
  late final VideoPlayerController _videoPlayerController;
  late final StreamController<VideoDetail> _videoStreamController;
  late final StreamSubscription<VideoDetail> _videoStreamSubscription;
  bool _videoInitialized = false;

  @override
  Future<void> close() {
    _videoPlayerController.dispose();
    return super.close();
  }

  Future<void> initialize(String videoId) async {
    try {
      _videoId = videoId;
      _videoStreamController = _repository.videoDetailStreamController;
      await _repository.getVideoDetailStream(videoId);
      _videoStreamSubscription =
          _videoStreamController.stream.listen((videoDetail) {
        _video = videoDetail;
        if (state is VideoInitial) {
          emit(VideoLoading(_video));
        } else if (state is VideoLoading) {
          emit(VideoLoading(_video));
        } else if (state is VideoPlaying) {
          emit(VideoPlaying(
            video: _video,
            videoPlayerController: _videoPlayerController,
          ));
        } else if (state is VideoError) {
          emit(VideoPlaying(
            video: _video,
            videoPlayerController: _videoPlayerController,
          ));
        }
      });

      _videoPlayerController = VideoPlayerController.network(_video.url);
      await _videoPlayerController.initialize();
      _videoInitialized = true;
      await _videoPlayerController.setLooping(true);
      await _videoPlayerController.play();
      emit(VideoPlaying(
        video: _video,
        videoPlayerController: _videoPlayerController,
      ));
    } catch (e) {
      emit(VideoError(message: 'Error loading video. Please refresh.'));
      return;
    }
  }

  Future<void> like() {
    return _repository.like(_videoId);
  }

  Future<void> unlike() {
    return _repository.unlike(_videoId);
  }
}
