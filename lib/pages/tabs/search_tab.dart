import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/components/video_list.dart';
import 'package:spot/cubits/search/search_cubit.dart';

import '../../repositories/repository.dart';
import '../../utils/constants.dart';

class SearchTab extends StatefulWidget {
  static Widget create() {
    return BlocProvider<SearchCubit>(
      create: (context) =>
          SearchCubit(repository: RepositoryProvider.of<Repository>(context))
            ..loadInitialVideos(),
      child: SearchTab(),
    );
  }

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _queryStringController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 30,
          ),
          child: TextFormField(
            controller: _queryStringController,
            onEditingComplete: _search,
            decoration: InputDecoration(
              hintText: 'Search by ',
              suffixIcon: IconButton(
                icon: const Icon(
                  FeatherIcons.search,
                  color: Color(0xFFFFFFFF),
                ),
                onPressed: _search,
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
        ),
        BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return preloader;
            } else if (state is SearchLoaded) {
              final videos = state.videos;
              return VideoList(videos: videos);
            } else if (state is SearchEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child:
                      Text('Sorry, we couldn\'t find what you are looking for'),
                ),
              );
            } else if (state is SearchError) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Something went wrong'),
                ),
              );
            }
            throw UnimplementedError(
                'Search Tab Unimplemented State ${state.runtimeType}');
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _queryStringController.dispose();
    super.dispose();
  }

  void _search() {
    if (_queryStringController.text.isEmpty) {
      return;
    }
    BlocProvider.of<SearchCubit>(context).search(_queryStringController.text);
    final currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
