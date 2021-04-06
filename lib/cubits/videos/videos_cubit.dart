import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/models/video.dart';
import 'package:spot/repositories/repository.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  VideosCubit({required Repository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(VideosInitial());

  final Repository _databaseRepository;

  final List<Video> _videos = [];

  Future<void> loadFromLocation() async {
    final location = await _databaseRepository.determinePosition();
    emit(VideosLoading(location));
    final res = await supabaseClient
        .rpc('nearby_videos', params: {
          'location': 'POINT(${location.latitude} ${location.longitude})'
        })
        .limit(20)
        .execute();
    final error = res.error;
    final data = res.data;
    if (error != null) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
      return;
    } else if (data == null) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
      return;
    }

    _videos.addAll(Video.videosFromData(data));

    emit(VideosLoaded(_videos));
  }

  Future<void> loadFromUid(String uid) async {
    final res = await supabaseClient
        .from('videos')
        .select()
        .eq('user_id', uid)
        .execute();
    final error = res.error;
    final data = res.data;
    if (error != null) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
      return;
    } else if (data == null) {
      emit(VideosError(message: 'Error loading videos. Please refresh.'));
      return;
    }

    _videos.addAll(Video.videosFromData(data));

    emit(VideosLoaded(_videos));
  }
}
