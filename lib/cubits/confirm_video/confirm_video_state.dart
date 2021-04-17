part of 'confirm_video_cubit.dart';

@immutable
abstract class ConfirmVideoState {}

class ConfirmVideoInitial extends ConfirmVideoState {}

class ConfirmVideoPlaying extends ConfirmVideoState {
  ConfirmVideoPlaying({required this.videoPlayerController});

  final CachedVideoPlayerController videoPlayerController;
}

class ConfirmVideoTranscoding extends ConfirmVideoState {
  ConfirmVideoTranscoding({required this.videoPlayerController});

  final CachedVideoPlayerController videoPlayerController;
}

class ConfirmVideoUploaded extends ConfirmVideoState {}

class ConfirmVideoError extends ConfirmVideoState {}
