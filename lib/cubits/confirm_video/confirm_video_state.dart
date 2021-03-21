part of 'confirm_video_cubit.dart';

@immutable
abstract class ConfirmVideoState {}

class ConfirmVideoInitial extends ConfirmVideoState {}

class ConfirmVideoPlaying extends ConfirmVideoState {
  ConfirmVideoPlaying({required this.videoPlayerController});

  final VideoPlayerController videoPlayerController;
}
