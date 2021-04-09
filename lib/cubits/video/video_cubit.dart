import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/app/constants.dart';
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
  VideoDetail? _videoDetail;
  VideoPlayerController? _videoPlayerController;
  StreamSubscription<VideoDetail?>? _videoStreamSubscription;

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
      final videoStreamController = _repository.videoDetailStreamController;

      // ignore: unawaited_futures
      _repository.getVideoDetailStream(videoId);
      _videoStreamSubscription =
          videoStreamController.stream.listen((videoDetail) {
        if (videoDetail != null) {
          _videoDetail = videoDetail;
          _initializeVideo();
          if (state is VideoInitial) {
            emit(VideoLoading(_videoDetail!));
          } else if (state is VideoLoading) {
            emit(VideoLoading(_videoDetail!));
          } else if (state is VideoPlaying) {
            emit(VideoPlaying(
              video: _videoDetail!,
              videoPlayerController: _videoPlayerController!,
            ));
          }
        }
      });
    } catch (err) {
      emit(VideoError(message: 'Error loading video. Please refresh.'));
    }
  }

  Future<void> like() {
    try {
      return _repository.like(_videoId);
    } catch (err) {
      emit(VideoError(message: 'Error liking the video'));
      return Future.error(err);
    }
  }

  Future<void> unlike() {
    try {
      return _repository.unlike(_videoId);
    } catch (err) {
      emit(VideoError(message: 'Error unliking the video.'));
      return Future.error(err);
    }
  }

  Future<void> showComments() async {
    try {
      _isCommentsShown = true;
      emit(VideoPlaying(
        video: _videoDetail!,
        videoPlayerController: _videoPlayerController!,
        isCommentsShown: _isCommentsShown,
        comments: _comments,
      ));
      _comments ??= await _repository.getComments(_videoId);
      emit(VideoPlaying(
        video: _videoDetail!,
        videoPlayerController: _videoPlayerController!,
        isCommentsShown: _isCommentsShown,
        comments: _comments,
      ));
    } catch (err) {
      emit(VideoError(message: 'Error opening comments of the video.'));
    }
  }

  void hideComments() {
    _isCommentsShown = false;
    emit(VideoPlaying(
      video: _videoDetail!,
      videoPlayerController: _videoPlayerController!,
      isCommentsShown: _isCommentsShown,
    ));
  }

  Future<void> comment(String text) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      final user = await _repository.getProfile(userId);
      final comment = Comment(
        id: 'new',
        text: text,
        createdAt: DateTime.now(),
        videoId: _videoId,
        user: user!,
      );
      _comments!.insert(0, comment);
      emit(VideoPlaying(
        video: _videoDetail!,
        videoPlayerController: _videoPlayerController!,
        isCommentsShown: _isCommentsShown,
        comments: _comments,
      ));
      await _repository.comment(text: text, videoId: _videoId);
    } catch (err) {
      emit(VideoError(message: 'Error commenting.'));
    }
  }

  Future<void> _initializeVideo() async {
    if (_videoPlayerController == null) {
      _videoPlayerController = VideoPlayerController.network(_videoDetail!.url);
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(true);
      await _videoPlayerController!.play();

      emit(VideoPlaying(
        video: _videoDetail!,
        videoPlayerController: _videoPlayerController!,
      ));
    }
  }
}
