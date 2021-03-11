part of 'videos_cubit.dart';

@immutable
abstract class VideosState {}

class VideosInitial extends VideosState {}

class VideosLoaded extends VideosState {
  VideosLoaded(this.videos);

  final List<Video> videos;
}
