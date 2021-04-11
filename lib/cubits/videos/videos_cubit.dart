import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/video.dart';
import 'package:spot/repositories/repository.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  VideosCubit({required Repository databaseRepository})
      : _repository = databaseRepository,
        super(VideosInitial());

  final Repository _repository;

  StreamSubscription<List<Video>>? _mapVideosSubscription;

  @override
  Future<void> close() {
    _mapVideosSubscription?.cancel();
    return super.close();
  }

  Future<void> loadFromLocation() async {
    try {
      final location = await _repository.determinePosition();
      emit(VideosLoading(location));
      _mapVideosSubscription =
          _repository.mapVideosStreamConntroller.stream.listen((videos) {
        emit(VideosLoaded(videos));
      });
      await _repository.getVideosFromLocation(location);
    } catch (err) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
    }
  }

  Future<void> loadFromUid(String uid) async {
    try {
      final videos = await _repository.getVideosFromUid(uid);
      emit(VideosLoaded(videos));
    } catch (err) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
    }
  }
}
