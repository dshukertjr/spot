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
  /// Takes care of actions done on single video
  /// like viewing liking, blocking and such
  VideoCubit({required Repository repository})
      : _repository = repository,
        super(VideoInitial());

  final Repository _repository;

  late final String _videoId;
  VideoDetail? _videoDetail;
  VideoPlayerController? _videoPlayerController;
  StreamSubscription<VideoDetail?>? _videoStreamSubscription;

  @override
  Future<void> close() {
    _videoPlayerController?.dispose();
    _videoStreamSubscription?.cancel();
    return super.close();
  }

  /// Set up listener to listen to video data emitted in repository.
  Future<void> initialize(String videoId) async {
    try {
      _videoId = videoId;
      await _repository.getVideoDetailStream(videoId);

      _videoStreamSubscription =
          _repository.videoDetailStream.listen((videoDetail) {
        if (videoDetail != null) {
          _videoDetail = videoDetail;
          _initializeVideo();
          if (state is VideoInitial) {
            emit(VideoLoading(_videoDetail!));
          } else if (state is VideoLoading) {
            emit(VideoLoading(_videoDetail!));
          } else if (state is VideoPlaying) {
            final videoPlayerContoller = _videoPlayerController;
            if (videoPlayerContoller == null) {
              emit(VideoError(message: 'Video player failed to load.'));
            } else {
              emit(VideoPlaying(
                videoDetail: _videoDetail!,
                videoPlayerController: videoPlayerContoller,
              ));
            }
          }
        }
      });
    } catch (err) {
      emit(VideoError(message: 'Error loading video. Please refresh.'));
    }
  }

  /// Like a video.
  Future<void> like() {
    try {
      return _repository.like(_videoDetail!);
    } catch (err) {
      emit(VideoError(message: 'Error liking the video'));
      return Future.error(err);
    }
  }

  /// Unlike a video.
  Future<void> unlike() {
    try {
      return _repository.unlike(_videoDetail!);
    } catch (err) {
      emit(VideoError(message: 'Error unliking the video.'));
      return Future.error(err);
    }
  }

  /// Block the creator of the video.
  Future<void> block(String blockedUserId) {
    return _repository.block(blockedUserId);
  }

  /// Report this video.
  Future<void> report({
    required String videoId,
    required String reason,
  }) {
    return _repository.report(
      videoId: videoId,
      reason: reason,
    );
  }

  /// Delete this video. Can only be performed by the creator.
  Future<void> delete() {
    return _repository.delete(videoId: _videoId);
  }

  /// Share this video.
  Future<void> shareVideo() {
    return _repository.shareVideo(_videoDetail!);
  }

  Future<void> _initializeVideo() async {
    try {
      if (_videoPlayerController == null) {
        _videoPlayerController =
            await _repository.getVideoPlayerController(_videoDetail!.url);
        await _videoPlayerController!.initialize();
        await _videoPlayerController!.play();

        emit(VideoPlaying(
          videoDetail: _videoDetail!,
          videoPlayerController: _videoPlayerController!,
        ));
      }
    } catch (err) {
      emit(VideoError(message: 'Video failed to load'));
    }
  }
}
