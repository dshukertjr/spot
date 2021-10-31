part of 'search_cubit.dart';

@immutable

/// Base state of search
abstract class SearchState {}

/// Loading search.
class SearchLoading extends SearchState {}

/// Completed search and search results were found.
class SearchLoaded extends SearchState {
  /// Completed search and search results were found.
  SearchLoaded(this.videos);

  /// Videos found.
  final List<Video> videos;
}

/// No videos were found.
class SearchEmpty extends SearchState {}

/// Error occured while performing search.
class SearchError extends SearchState {}
