import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';
import 'package:spot/repositories/repository.dart';

part 'record_state.dart';

/// Cubit that takes care of recording.
class RecordCubit extends Cubit<RecordState> {
  /// Cubit that takes care of recording.
  RecordCubit({
    required Repository repository,
  })  : _repository = repository,
        super(RecordInitial());
  final Repository _repository;

  CameraController? _controller;

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }

  /// Initializes the camera
  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(RecordError('No available cameras found'));
        return;
      }

      _controller = CameraController(cameras.first, ResolutionPreset.high);
      await _controller!.initialize();
      await _controller!.prepareForVideoRecording();
      emit(RecordReady(controller: _controller!));
    } catch (e) {
      emit(RecordError('Camera initialization error'));
    }
  }

  /// Starts recording the video
  Future<void> startRecording() async {
    if (state is RecordReady) {
      await _controller!.startVideoRecording();
      emit(RecordInProgress(controller: _controller!));
    } else if (state is RecordPaused) {
      await _controller!.resumeVideoRecording();
      emit(RecordInProgress(controller: _controller!));
    }
  }

  /// Pauses recording.
  Future<void> pauseRecording() async {
    await _controller!.pauseVideoRecording();
    emit(RecordPaused(controller: _controller!));
  }

  /// Completes the recording.
  Future<void> doneRecording() async {
    emit(RecordProcessing(controller: _controller!));

    // stopVideoRecording takes about a whole second
    final videoXFile = await _controller!.stopVideoRecording();
    final videoFile = File(videoXFile.path);
    emit(
      RecordCompleted(controller: _controller!, videoFile: videoFile),
    );
  }

  /// Opens video library on user's device to choose the video to be uploaded
  Future<void> uploadVideo() async {
    final videoPickedFile = await _repository.getVideoFile();
    if (videoPickedFile != null) {
      final videoFile = File(videoPickedFile.path);
      emit(RecordCompleted(controller: _controller!, videoFile: videoFile));
    }
  }
}
