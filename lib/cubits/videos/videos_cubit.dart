import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  VideosCubit() : super(VideosInitial());

  final List<Video> _videos = [
    Video(
      id: '',
      createdAt: DateTime.now(),
      createdBy: Profile(
        id: '',
        name: 'aaa',
        imageUrl:
            'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      ),
      description: '',
      videoImageUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      thumbnailUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
      position: const LatLng(37.43296265331129, -122.08832357078792),
    ),
    Video(
      id: 'aaa',
      createdAt: DateTime.now(),
      createdBy: Profile(
        id: '',
        name: 'aaa',
        imageUrl:
            'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      ),
      description: '',
      videoImageUrl:
          'https://www.vegrecipesofindia.com/wp-content/uploads/2020/11/pizza-recipe.jpg',
      thumbnailUrl:
          'https://www.vegrecipesofindia.com/wp-content/uploads/2020/11/pizza-recipe.jpg',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
      position: const LatLng(37.44307275331129, -122.08832357078792),
    ),
  ];

  Future<void> initialize() async {
    // TODO receive geo point and get videos
    await Future.delayed(const Duration(seconds: 1));
    emit(VideosLoaded(_videos));
  }
}
