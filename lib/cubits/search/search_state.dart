part of 'search_cubit.dart';

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  SearchLoaded(this.videos);
  final List<Video> videos;
}

class SearchEmpty extends SearchState {}

class SearchError extends SearchState {}
