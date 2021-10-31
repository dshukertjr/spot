part of 'record_cubit.dart';

@immutable

/// Base state for Recordinng
abstract class RecordState {}

/// Initial state of recording.
class RecordInitial extends RecordState {}

/// Camera is ready to start recording.
class RecordReady extends RecordState {
  /// Camera is ready to start recording.
  RecordReady({required this.controller});

  /// CameraController of device's camera.
  final CameraController controller;
}

/// State where recording is in progress.
class RecordInProgress extends RecordState {
  /// State where recording is in progress.
  RecordInProgress({required this.controller});

  /// CameraController of device's camera.
  final CameraController controller;
}

/// Recording has been paused.
class RecordPaused extends RecordState {
  /// Recording has been paused.
  RecordPaused({required this.controller});

  /// CameraController of device's camera.
  final CameraController controller;
}

/// Finished recording and processing the recording.
class RecordProcessing extends RecordState {
  /// Finished recording and processing the recording.
  RecordProcessing({required this.controller});

  /// CameraController of device's camera.
  final CameraController controller;
}

/// Recording has finished and processing has finished.
class RecordCompleted extends RecordState {
  /// Recording has finished and processing has finished.
  RecordCompleted({
    required this.controller,
    required this.videoFile,
  });

  /// CameraController of device's camera.
  final CameraController controller;

  /// File of the recorded video.
  final File videoFile;
}

/// State where error occured during recording.
class RecordError extends RecordState {
  /// State where error occured during recording.
  RecordError(this.errorMessage);

  /// Error message to be shown to the user.
  final String errorMessage;
}
