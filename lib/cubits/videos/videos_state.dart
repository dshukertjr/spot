part of 'videos_cubit.dart';

@immutable
abstract class VideosState {}

class VideosInitial extends VideosState {}

class VideosLoading extends VideosState {
  VideosLoading(this.location);

  final LatLng location;
}

class VideosLoadingMore extends VideosState {
  VideosLoadingMore(this.videos);

  final List<Video> videos;
}

class VideosLoaded extends VideosState {
  VideosLoaded(this.videos);

  final List<Video> videos;
}

class VideosError extends VideosState {
  VideosError({required this.message});

  final String message;
}
