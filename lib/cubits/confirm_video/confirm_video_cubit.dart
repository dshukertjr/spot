import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

part 'confirm_video_state.dart';

class ConfirmVideoCubit extends Cubit<ConfirmVideoState> {
  ConfirmVideoCubit() : super(ConfirmVideoInitial());

  late final VideoPlayerController _videoPlayerController;

  final _flutterFFmpeg = FlutterFFmpeg();

  bool _doneCompressingVideo = false;
  late final File _compressedVideo;
  late final File _videoImage;
  late final File _thumbnail;
  late final File _gif;

  Future<void> initialize({required XFile videoFile}) async {
    try {
      final videoPath = videoFile.path;
      _videoPlayerController = VideoPlayerController.file(File(videoPath));
      await _videoPlayerController.setLooping(true);
      await _videoPlayerController.initialize();
      await _videoPlayerController.play();
      emit(ConfirmVideoPlaying(videoPlayerController: _videoPlayerController));

      final tempDir = await getTemporaryDirectory();
      final videoTempPath = '${tempDir.path}/temp.mp4';
      _compressedVideo =
          await _compressVideo(videoPath: videoPath, tempPath: videoTempPath);

      final videoImageTempPath = '${tempDir.path}/tempImage.jpg';
      _videoImage = await _getVideoImage(
          videoPath: videoPath, tempPath: videoImageTempPath);

      final thubmnailTempPath = '${tempDir.path}/tempThumb.jpg';
      _thumbnail = await _getVideoThumbnail(
          videoPath: _videoImage.path, tempPath: thubmnailTempPath);

      final gifTempPath = '${tempDir.path}/temp.gif';
      _gif = await _getGif(videoPath: videoPath, tempPath: gifTempPath);

      _doneCompressingVideo = true;
    } catch (e) {
      //TODO handle error in better way
      emit(ConfirmVideoError());
    }
  }

  Future<void> post() async {
    emit(
        ConfirmVideoTranscoding(videoPlayerController: _videoPlayerController));

    /// wait until video processing is complete
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return !_doneCompressingVideo;
    });

    /// TODO Upload the videos to supabase
    emit(ConfirmVideoUploaded());
  }

  Future<File> _compressVideo({
    required String videoPath,
    required String tempPath,
  }) async {
    final command =
        '-y -i $videoPath -c:v libx264 -preset veryfast -tune zerolatency -filter:v scale=-2:720 $tempPath';
    final res = await _flutterFFmpeg.execute(command);
    if (res != 0) {
      throw PlatformException(
        code: 'ffmpeg error',
        message: 'ffmpeg failed to compress video',
      );
    }
    return File(tempPath);
  }

  Future<File> _getVideoImage({
    required String videoPath,
    required String tempPath,
  }) async {
    final command =
        '-y -i $videoPath -vframes 1 -filter:v scale="-2:-720" $tempPath';
    final res = await _flutterFFmpeg.execute(command);
    if (res != 0) {
      throw PlatformException(
        code: 'ffmpeg error',
        message: 'ffmpeg failed to get video image',
      );
    }
    return File(tempPath);
  }

  Future<File> _getVideoThumbnail({
    required String videoPath,
    required String tempPath,
  }) async {
    final command =
        '-y -i $videoPath -vf "scale=200:-2, crop=200:200:exact=1" $tempPath';
    final res = await _flutterFFmpeg.execute(command);
    if (res != 0) {
      throw PlatformException(
        code: 'ffmpeg error',
        message: 'ffmpeg failed to get image thumbnail',
      );
    }
    return File(tempPath);
  }

  Future<File> _getGif({
    required String videoPath,
    required String tempPath,
  }) async {
    final command = '-y -t 3 -i $videoPath -vf scale=-2:120 -r 10 $tempPath';
    final res = await _flutterFFmpeg.execute(command);
    if (res != 0) {
      throw PlatformException(
        code: 'ffmpeg error',
        message: 'ffmpeg failed to get gif',
      );
    }
    return File(tempPath);
  }
}
