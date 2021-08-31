import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/videos/videos_cubit.dart';
import 'package:spot/models/video.dart';
import '../helpers/helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue<LatLngBounds>(LatLngBounds(
        southwest: const LatLng(0, 0), northeast: const LatLng(45, 45)));
  });
  test('Initial State', () {
    final repository = MockRepository();
    expect(VideosCubit(repository: repository).state is VideosInitial, true);
  });

  group('VideosCubit loadFromLocation()', () {
    blocTest<VideosCubit, VideosState>(
      'Can load initial videos from location',
      build: () {
        final repository = MockRepository();
        when(repository.determinePosition)
            .thenAnswer((invocation) => Future.value(const LatLng(0, 0)));
        when(() => repository.mapVideosStream).thenAnswer((_) => Stream.value([
              Video(
                id: 'id',
                url: 'url',
                imageUrl: '',
                thumbnailUrl: 'thumbnailUrl',
                gifUrl: 'gifUrl',
                createdAt: DateTime.now(),
                description: 'description',
                userId: 'userId',
                location: const LatLng(0, 0),
                isFollowing: false,
              ),
            ]));
        when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
            .thenAnswer((_) => Future.value([
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
                  ),
                ]));
        return VideosCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadInitialVideos();
      },
      expect: () => [
        isA<VideosLoading>(),
        isA<VideosLoaded>(),
      ],
    );

    blocTest<VideosCubit, VideosState>(
      'Can load videos from location',
      build: () {
        final repository = MockRepository();
        when(repository.determinePosition)
            .thenAnswer((invocation) async => const LatLng(0, 0));
        when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
            .thenAnswer(
          (_) => Future.value([
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
            ),
          ]),
        );
        when(() => repository.mapVideosStream)
            .thenAnswer((invocation) => Stream.value([
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
                  ),
                ]));
        return VideosCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadInitialVideos();
      },
      expect: () => [
        isA<VideosLoading>(),
        isA<VideosLoaded>(),
      ],
    );
    blocTest<VideosCubit, VideosState>(
      'Can load videos of a user',
      build: () {
        final repository = MockRepository();
        when(() => repository.getVideosFromUid(''))
            .thenAnswer((_) => Future.value([
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
                  ),
                ]));
        return VideosCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadFromUid('');
      },
      expect: () => [
        isA<VideosLoaded>(),
      ],
    );
    blocTest<VideosCubit, VideosState>(
      'Get initial videos from location and load more afterwards',
      build: () {
        final repository = MockRepository();
        when(repository.determinePosition)
            .thenAnswer((invocation) async => const LatLng(0, 0));
        when(() => repository.mapVideosStream).thenAnswer((_) => Stream.value([
              Video(
                id: 'id',
                url: 'url',
                imageUrl: '',
                thumbnailUrl: 'thumbnailUrl',
                gifUrl: 'gifUrl',
                createdAt: DateTime.now(),
                description: 'description',
                userId: 'userId',
                location: const LatLng(0, 0),
                isFollowing: false,
              ),
            ]));
        when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
            .thenAnswer((_) => Future.value([
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
                  ),
                ]));
        when(() => repository.getVideosInBoundingBox(any<LatLngBounds>()))
            .thenAnswer((_) => Future.value([
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
                  ),
                ]));
        return VideosCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadInitialVideos();
        await Future.delayed(const Duration(seconds: 3));
        await cubit.loadVideosWithinBoundingBox(LatLngBounds(
            southwest: const LatLng(0, 0), northeast: const LatLng(45, 45)));
      },
      expect: () => [
        isA<VideosLoading>(),
        isA<VideosLoaded>(),
        isA<VideosLoadingMore>(),
      ],
    );
  });
}
