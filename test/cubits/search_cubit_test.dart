import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/search/search_cubit.dart';
import 'package:spot/models/video.dart';

import '../helpers/helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  group('SearchCubit', () {
    test('Initial State', () {
      final repository = MockRepository();
      when(() => repository.search('')).thenAnswer((_) => Future.value());
      expect(SearchCubit(repository: repository).state is SearchLoading, true);
    });

    blocTest<SearchCubit, SearchState>(
      'empty search results',
      build: () {
        final repository = MockRepository();
        when(() => repository.search('')).thenAnswer((_) => Future.value([]));
        return SearchCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.search('');
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchEmpty>(),
      ],
    );
    blocTest<SearchCubit, SearchState>(
      'has search results',
      build: () {
        final repository = MockRepository();
        when(() => repository.search('')).thenAnswer((_) => Future.value([
              Video(
                id: 'id',
                url: 'url',
                imageUrl: 'imageUrl',
                thumbnailUrl: 'thumbnailUrl',
                gifUrl: 'gifUrl',
                createdAt: DateTime.now(),
                description: 'description',
                userId: 'userId',
                location: const LatLng(0, 0),
                isFollowing: false,
              )
            ]));
        return SearchCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.search('');
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>(),
      ],
    );
    blocTest<SearchCubit, SearchState>(
      'has search results',
      build: () {
        final repository = MockRepository();
        when(() => repository.search(''))
            .thenThrow(PlatformException(code: ''));
        return SearchCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.search('');
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchError>(),
      ],
    );
  });
}
