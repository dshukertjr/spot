import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/models/video.dart';
import 'package:spot/repositories/repository.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  VideosCubit({required Repository databaseRepository})
      : _repository = databaseRepository,
        super(VideosInitial());

  final Repository _repository;

  final List<Video> _videos = [];

  Future<void> loadFromLocation() async {
    final location = await _repository.determinePosition();
    emit(VideosLoading(location));
    try {
      final videos = await _repository.getVideosFromLocation(location);
      _videos.addAll(videos);
      emit(VideosLoaded(_videos));
    } catch (e) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
    }
  }

  Future<void> loadFromUid(String uid) async {
    try {
      final videos = await _repository.getVideosFromUid(uid);
      _videos.addAll(videos);
      emit(VideosLoaded(_videos));
    } catch (e) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
    }
  }
}
