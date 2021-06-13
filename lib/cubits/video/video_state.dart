part of 'video_cubit.dart';

@immutable
abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {
  VideoLoading(this.videoDetail);

  final VideoDetail videoDetail;
}

class VideoPlaying extends VideoState {
  VideoPlaying({
    required this.videoDetail,
    this.videoPlayerController,
  });

  final VideoDetail videoDetail;
  final VideoPlayerController? videoPlayerController;
}

class VideoError extends VideoState {
  VideoError({required this.message});

  final String message;
}
