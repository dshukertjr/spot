import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spot/models/video.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/constants.dart';

part 'confirm_video_state.dart';

/// Cubit that takes care of video transcoding
/// while the user confirms the video.
class ConfirmVideoCubit extends Cubit<ConfirmVideoState> {
  /// Cubit that takes care of video transcoding
  /// while the user confirms the video.
  ConfirmVideoCubit({required Repository repository})
      : _repository = repository,
        super(ConfirmVideoInitial());

  final Repository _repository;

  late final BetterPlayerController _videoPlayerController;

  final _flutterFFmpeg = FlutterFFmpeg();

  final _compressingVideoCompleter = Completer();
  LatLng? _videoLocation;
  late final File _compressedVideo;
  late final File _videoImage;
  late final File _thumbnail;
  late final File _gif;

  /// Initialize the transcoding in the background
  Future<void> initialize({required File videoFile}) async {
    try {
      final videoPath = videoFile.path;
      final config = const BetterPlayerConfiguration(
          controlsConfiguration:
              BetterPlayerControlsConfiguration(showControls: false));
      final dataSource = BetterPlayerDataSource.file(videoPath);
      _videoPlayerController =
          BetterPlayerController(config, betterPlayerDataSource: dataSource);
      await _videoPlayerController.play();
      emit(ConfirmVideoPlaying(videoPlayerController: _videoPlayerController));

      _videoLocation = await _repository.getVideoLocation(videoPath);

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

      _compressingVideoCompleter.complete();
    } catch (e) {
      emit(ConfirmVideoError());
    }
  }

  /// Submits the video to be saved on Supabase
  Future<void> post({required String description}) async {
    emit(ConfirmVideoUploading(videoPlayerController: _videoPlayerController));

    /// wait until video processing is complete
    await _compressingVideoCompleter.future;

    // If the video does not have location metadata, get the current location
    _videoLocation ??= await _repository.determinePosition();

    final userId = _repository.userId;
    if (userId == null) {
      throw PlatformException(code: 'Not Signed In');
    }

    try {
      final now = DateTime.now();
      final videoPath =
          '$userId/${now.millisecondsSinceEpoch}.${_compressedVideo.path.split('.').last}';
      final videoUrl = await _repository.uploadFile(
          bucket: 'videos', file: _compressedVideo, path: videoPath);

      final videoImagePath =
          '$userId/${now.millisecondsSinceEpoch}.${_videoImage.path.split('.').last}';
      final videoImageUrl = await _repository.uploadFile(
          bucket: 'videos', file: _videoImage, path: videoImagePath);

      final videoThumbPath =
          '$userId/thumb-${now.millisecondsSinceEpoch}.${_thumbnail.path.split('.').last}';
      final videoThumbUrl = await _repository.uploadFile(
          bucket: 'videos', file: _thumbnail, path: videoThumbPath);

      final videoGifPath =
          '$userId/${now.millisecondsSinceEpoch}.${_gif.path.split('.').last}';
      final videoGifUrl = await _repository.uploadFile(
          bucket: 'videos', file: _gif, path: videoGifPath);

      final creatingVideo = Video.creation(
        videoUrl: videoUrl,
        videoImageUrl: videoImageUrl,
        thumbnailUrl: videoThumbUrl,
        gifUrl: videoGifUrl,
        description: description,
        creatorUid: userId,
        position: _videoLocation!,
      );

      await _repository.saveVideo(creatingVideo);

      emit(ConfirmVideoUploaded());
    } catch (err) {
      emit(ConfirmVideoError());
    }
  }

  Future<File> _compressVideo({
    required String videoPath,
    required String tempPath,
  }) async {
    ///  -movflags +faststart optimizes video for web streaming
    /// by bringing some of the headers upfront
    final command =
        '-t ${maxVideoDuration.inSeconds} -y -i $videoPath -c:v libx264 '
        '-preset veryfast -tune zerolatency -movflags '
        '+faststart -filter:v scale=-2:720 $tempPath';
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
        '-y -i $videoPath -vframes 1 -filter:v scale="-2:720" $tempPath';
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
    /// -y overrides the output file
    /// -i ${filePath} input file path
    ///
    final command = '-y -i $videoPath -vf "crop=w=\'min(iw\,ih)\''
        ':h=\'min(iw\,ih)\',scale=200:200,setsar=1" $tempPath';
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
    /// -y overrides the output file
    /// -t 2 creates a 2 second gif
    /// -i ${filePath} input file path
    /// -vf scale=-2:240 sets the height at 240 and width
    /// at the same aspect ratio
    final command = '-y -t 2 -i $videoPath -vf scale=-2:240 -r 10 $tempPath';
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
