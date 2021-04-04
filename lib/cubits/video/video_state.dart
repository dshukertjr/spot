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
  });

  final VideoDetail video;
  final VideoPlayerController videoPlayerController;
}

class VideoPaused extends VideoState {
  VideoPaused({
    required this.video,
    required this.videoPlayerController,
  });

  final VideoDetail video;
  final VideoPlayerController videoPlayerController;
}

class VideoError extends VideoState {
  VideoError({required this.message});

  final String message;
}
