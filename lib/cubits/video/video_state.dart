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
    bool? isCommentsShown,
    this.comments,
    this.mentionSuggestions,
    this.isLoadingMentions = false,
  }) : isCommentsShown = isCommentsShown ?? false;

  final VideoDetail videoDetail;
  final VideoPlayerController? videoPlayerController;
  final bool isCommentsShown;
  final List<Comment>? comments;
  final List<Profile>? mentionSuggestions;
  final bool isLoadingMentions;
}

class VideoError extends VideoState {
  VideoError({required this.message});

  final String message;
}
