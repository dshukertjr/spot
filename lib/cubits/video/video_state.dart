part of 'video_cubit.dart';

@immutable

/// Base state of video.
abstract class VideoState {}

/// Initial state of video state
class VideoInitial extends VideoState {}

/// Loading a video.
class VideoLoading extends VideoState {
  /// Loading a video.
  VideoLoading(this.videoDetail);

  /// Video data of loaded video.
  final VideoDetail videoDetail;
}

/// State when the video is being played.
class VideoPlaying extends VideoState {
  /// State when the video is being played.
  VideoPlaying({
    required this.videoDetail,
    required this.videoPlayerController,
  });

  /// Video data of the playing video.
  final VideoDetail videoDetail;

  /// VideoPlayerController of the playing video.
  final VideoPlayerController videoPlayerController;
}

/// State to be emitted when an error occured.
class VideoError extends VideoState {
  /// State to be emitted when an error occured.
  VideoError({required this.message});

  /// Error message to be displayed to the user.
  final String message;
}
