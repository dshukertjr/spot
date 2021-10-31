import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/video.dart';
import '../../repositories/repository.dart';
part 'search_state.dart';

/// Cubit that takes care of key word search.
class SearchCubit extends Cubit<SearchState> {
  /// Cubit that takes care of key word search.
  SearchCubit({required Repository repository})
      : _repository = repository,
        super(SearchLoading());

  final Repository _repository;

  /// Load some videos to be initially shown to users prior to performing serach
  Future<void> loadInitialVideos() async {
    try {
      final videos = await _repository.getNewVideos();
      if (videos.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchLoaded(videos));
      }
    } catch (err) {
      emit(SearchError());
    }
  }

  /// Perform a keyword search.
  Future<void> search(String queryString) async {
    try {
      emit(SearchLoading());
      final videos = await _repository.search(queryString);
      if (videos.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchLoaded(videos));
      }
    } catch (err) {
      emit(SearchError());
    }
  }
}
