import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';

part 'record_state.dart';

class RecordCubit extends Cubit<RecordState> {
  RecordCubit() : super(RecordInitial());
  late CameraController _controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller.initialize();
    emit(RecordInProgress(controller: _controller));
  }

  Future<void> startRecording() async {
    await _controller.startVideoRecording();
    emit(RecordInProgress(controller: _controller));
  }

  Future<void> pauseRecording() async {
    await _controller.pauseVideoRecording();
    emit(RecordPaused(controller: _controller));
  }

  Future<void> resumeRecording() async {
    await _controller.resumeVideoRecording();
    emit(RecordInProgress(controller: _controller));
  }

  Future<void> doneRecording() async {
    await _controller.stopVideoRecording();
    // TODO do something that will take the user to the next step
  }

  @override
  Future<void> close() {
    _controller.dispose();
    return super.close();
  }
}
