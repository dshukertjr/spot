part of 'record_cubit.dart';

@immutable
abstract class RecordState {}

class RecordInitial extends RecordState {}

class RecordInProgress extends RecordState {
  RecordInProgress({required this.controller});

  final CameraController controller;
}

class RecordPaused extends RecordState {
  RecordPaused({required this.controller});

  final CameraController controller;
}
