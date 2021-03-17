import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

import '../../models/profile.dart';
import '../../models/video.dart';

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
    final video = Video(
      id: '',
      createdAt: DateTime.now(),
      createdBy: Profile(
        id: '',
        name: 'aaa',
        imageUrl:
            'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      ),
      description: 'This is just a sample description',
      thumbnailUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
    );
    emit(VideoPlaying(
      video: video,
      videoPlayerController: _videoPlayerController,
    ));
  }

  @override
  Future<void> close() {
    _videoPlayerController.dispose();
    return super.close();
  }
}
