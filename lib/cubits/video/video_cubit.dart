import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/comment.dart';
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
  late final VideoDetail _videoDetail;
  VideoPlayerController? _videoPlayerController;
  late final StreamController<VideoDetail> _videoStreamController;
  StreamSubscription<VideoDetail>? _videoStreamSubscription;

  List<Comment>? _comments;

  bool _isCommentsShown = false;

  @override
  Future<void> close() {
    _videoPlayerController?.dispose();
    _videoStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> initialize(String videoId) async {
    try {
      _videoId = videoId;
      _videoStreamController = _repository.videoDetailStreamController;
      await _repository.getVideoDetailStream(videoId);
      _videoStreamSubscription =
          _videoStreamController.stream.listen((videoDetail) {
        _videoDetail = videoDetail;
        _initializeVideo();
        if (state is VideoInitial) {
          emit(VideoLoading(_videoDetail));
        } else if (state is VideoLoading) {
          emit(VideoLoading(_videoDetail));
        } else if (state is VideoPlaying) {
          emit(VideoPlaying(
            video: _videoDetail,
            videoPlayerController: _videoPlayerController!,
          ));
        }
      });
    } catch (err, stack) {
      print(stack);
      emit(VideoError(message: 'Error loading video. Please refresh.'));
    }
  }

  Future<void> like() {
    return _repository.like(_videoId);
  }

  Future<void> unlike() {
    return _repository.unlike(_videoId);
  }

  Future<void> showComments() async {
    _isCommentsShown = true;
    emit(VideoPlaying(
      video: _videoDetail,
      videoPlayerController: _videoPlayerController!,
      isCommentsShown: _isCommentsShown,
    ));
    _comments ??= await _repository.getComments(_videoId);
    emit(VideoPlaying(
      video: _videoDetail,
      videoPlayerController: _videoPlayerController!,
      isCommentsShown: _isCommentsShown,
      comments: _comments,
    ));
  }

  void hideComments() {
    _isCommentsShown = false;
    emit(VideoPlaying(
      video: _videoDetail,
      videoPlayerController: _videoPlayerController!,
      isCommentsShown: _isCommentsShown,
    ));
  }

  Future<void> _initializeVideo() async {
    if (_videoPlayerController == null) {
      _videoPlayerController = VideoPlayerController.network(_videoDetail.url);
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(true);
      await _videoPlayerController!.play();

      emit(VideoPlaying(
        video: _videoDetail,
        videoPlayerController: _videoPlayerController!,
      ));
    }
  }
}
