import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

part 'video_state.dart';

/// Takes care of actions done on single video
/// like viewing liking, blocking and such
class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(VideoInitial());

  late final String _videoId;
  late final VideoPlayerController _videoPlayerController;

  Future<void> initialize(String videoId) async {
    // TODO get video data with videoId

    _videoPlayerController = VideoPlayerController.network(
        'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4');
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
    emit(VideoPlaying(videoPlayerController: _videoPlayerController));
  }

  @override
  Future<void> close() {
    _videoPlayerController.dispose();
    return super.close();
  }
}
