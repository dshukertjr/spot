import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/video.dart';
import 'package:spot/repositories/repository.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  VideosCubit({required Repository repository})
      : _repository = repository,
        super(VideosInitial());

  final Repository _repository;

  StreamSubscription<List<Video>>? _mapVideosSubscription;
  var _videos = <Video>[];

  @override
  Future<void> close() {
    _mapVideosSubscription?.cancel();
    return super.close();
  }

  Future<void> loadInitialVideos() async {
    try {
      final searchLocation = await _repository.determinePosition();
      emit(VideosLoading(searchLocation));
      await _repository.getVideosFromLocation(searchLocation);
      _mapVideosSubscription ??= _repository.mapVideosStream.listen((videos) {
        _videos = videos;
        emit(VideosLoaded(_videos));
      });
    } catch (err) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
    }
  }

  Future<void> loadVideosWithinBoundingBox(LatLngBounds bounds) async {
    try {
      emit(VideosLoadingMore(_videos));
      return _repository.getVideosInBoundingBox(bounds);
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

  Future<void> loadLikedPosts(String uid) async {
    try {
      final videos = await _repository.getLikedPostsFromUid(uid);
      emit(VideosLoaded(videos));
    } catch (e) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
    }
  }
}
