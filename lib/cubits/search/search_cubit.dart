import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/video.dart';
import '../../repositories/repository.dart';
part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required Repository repository})
      : _repository = repository,
        super(SearchLoading());

  final Repository _repository;

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
