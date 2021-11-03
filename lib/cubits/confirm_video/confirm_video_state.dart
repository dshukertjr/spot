part of 'confirm_video_cubit.dart';

@immutable

/// Base state for comfirm Video
abstract class ConfirmVideoState {}

/// Initial State
class ConfirmVideoInitial extends ConfirmVideoState {}

/// State where the video is playing on Confirmation page
class ConfirmVideoPlaying extends ConfirmVideoState {
  /// State where the video is playing on Confirmation page
  ConfirmVideoPlaying({required this.videoPlayerController});

  /// VideoPlayerController of the playing video
  final BetterPlayerController videoPlayerController;
}

/// State where it is waiting for the video to complete
/// transcoding and uploading.
class ConfirmVideoUploading extends ConfirmVideoState {
  /// State where it is waiting for the video to complete
  /// transcoding and uploading.
  ConfirmVideoUploading({required this.videoPlayerController});

  /// VideoPlayerController of the playing video
  final BetterPlayerController videoPlayerController;
}

/// State where the upload of the video has complete
class ConfirmVideoUploaded extends ConfirmVideoState {}

/// State where something went wrong while video processing
class ConfirmVideoError extends ConfirmVideoState {}
