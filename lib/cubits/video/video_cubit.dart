import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/app/constants.dart';
import 'package:video_player/video_player.dart';

import '../../models/video.dart';

part 'video_state.dart';

/// Takes care of actions done on single video
/// like viewing liking, blocking and such
class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(VideoInitial());

  late final String _videoId;
  late final VideoDetail _video;
  late final VideoPlayerController _videoPlayerController;
  bool _videoInitialized = false;

  Future<void> initialize(String videoId) async {
    _videoId = videoId;

    final res = await supabaseClient
        .from('video_detail')
        .select()
        .eq('id', _videoId)
        .execute();
    final data = res.data;
    final error = res.error;
    if (error != null) {
      emit(VideoError(message: 'Error loading video. Please refresh. '));
      return;
    } else if (data == null) {
      emit(VideoError(message: 'Error loading video. Please refresh. '));
      return;
    }

    _video = VideoDetail.fromData(Map.from(List.from(data).first));

    emit(VideoLoading(_video));

    _videoPlayerController = VideoPlayerController.network(_video.url);
    await _videoPlayerController.initialize();
    _videoInitialized = true;
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
    emit(VideoPlaying(
      video: _video,
      videoPlayerController: _videoPlayerController,
    ));
  }

  Future<void> pause() async {
    await _videoPlayerController.pause();
    if (!(state is VideoLoading)) {
      emit(VideoPaused(
        video: _video,
        videoPlayerController: _videoPlayerController,
      ));
    }
  }

  Future<void> resume() async {
    await _videoPlayerController.play();
    if (_videoInitialized) {
      emit(VideoPlaying(
        video: _video,
        videoPlayerController: _videoPlayerController,
      ));
    }
  }

  @override
  Future<void> close() {
    _videoPlayerController.dispose();
    return super.close();
  }
}
