part of 'video_cubit.dart';

@immutable
abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {
  VideoLoading(this.video);

  final VideoDetail video;
}

class VideoPlaying extends VideoState {
  VideoPlaying({
    required this.video,
    required this.videoPlayerController,
    bool? isCommentsShown,
    this.comments,
  }) : isCommentsShown = isCommentsShown ?? false;

  final VideoDetail video;
  final VideoPlayerController videoPlayerController;
  final bool isCommentsShown;
  final List<Comment>? comments;
}

class VideoError extends VideoState {
  VideoError({required this.message});

  final String message;
}
