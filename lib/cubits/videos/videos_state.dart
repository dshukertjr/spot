part of 'videos_cubit.dart';

@immutable

/// Base state of Videos.
abstract class VideosState {}

/// Initial state of Videos. Indicates loading.
class VideosInitial extends VideosState {}

/// State emitted when the location of the user has been determined, but
/// the videos are sill loading.
class VideosLoading extends VideosState {
  /// State emitted when the location of the user has been determined, but
  /// the videos are sill loading.
  VideosLoading(this.location);

  /// Location of the user.
  final LatLng location;
}

/// State where the user is requesting more videos to be loaded.
class VideosLoadingMore extends VideosState {
  /// State where the user is requesting more videos to be loaded.
  VideosLoadingMore(this.videos);

  /// Current videos to be shown to the user.
  final List<Video> videos;
}

/// Videos have been loaded and no further videos have been requested.
class VideosLoaded extends VideosState {
  /// Videos have been loaded and no further videos have been requested.
  VideosLoaded(this.videos);

  /// List of videos that were loaded.
  final List<Video> videos;
}

/// State to be emitted when an error occured.
class VideosError extends VideosState {
  /// State to be emitted when an error occured.
  VideosError({required this.message});

  /// Error message to be displayed to the user.
  final String message;
}
