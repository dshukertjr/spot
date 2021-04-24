import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/cubits/search/search_cubit.dart';
import 'package:spot/models/video.dart';

import '../../app/constants.dart';
import '../../repositories/repository.dart';
import '../view_video_page.dart';

class SearchTab extends StatefulWidget {
  static Widget create() {
    return BlocProvider<SearchCubit>(
      create: (context) => SearchCubit(repository: RepositoryProvider.of<Repository>(context)),
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
              hintText: 'Search away my friend',
              suffixIcon: IconButton(
                icon: const Icon(FeatherIcons.search),
                onPressed: _search,
              ),
            ),
          ),
        ),
        BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial) {
              return const Center(
                child: Text('Search anything you would like'),
              );
            } else if (state is SearchLoading) {
              return preloader;
            } else if (state is SearchLoaded) {
              final videos = state.videos;
              return _SearchResults(videos: videos);
            } else if (state is SearchEmpty) {
              return const Center(
                child: Text('Sorry, we couldn\'t find what you are looking for'),
              );
            } else if (state is SearchError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            throw UnimplementedError('Search Tab Unimplemented State ${state.runtimeType}');
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

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    Key? key,
    required this.videos,
  }) : super(key: key);

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: List.generate(videos.length, (index) {
          final video = videos[index];
          return FractionallySizedBox(
            widthFactor: 0.5,
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(ViewVideoPage.route(video.id));
                },
                child: Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 0),
                        valueColor: const AlwaysStoppedAnimation<Color>(appRed),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
