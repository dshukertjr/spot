part of 'record_cubit.dart';

@immutable
abstract class RecordState {}

class RecordInitial extends RecordState {}

class RecordReady extends RecordState {
  RecordReady({required this.controller});

  final CameraController controller;
}

class RecordInProgress extends RecordState {
  RecordInProgress({required this.controller});

  final CameraController controller;
}

class RecordPaused extends RecordState {
  RecordPaused({required this.controller});

  final CameraController controller;
}

class RecordProcessing extends RecordState {
  RecordProcessing({required this.controller});
  final CameraController controller;
}

class RecordCompleted extends RecordState {
  RecordCompleted({
    required this.controller,
    required this.videoFile,
  });
  final CameraController controller;
  final XFile videoFile;
}

class RecordError extends RecordState {
  RecordError(this.errorMessage);

  final String errorMessage;
}
