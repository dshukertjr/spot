import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:video_player/video_player.dart';

import '../helpers/helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  group('VideoCubit', () {
    final repository = MockRepository();
    when<Stream<VideoDetail?>>(() => repository.videoDetailStream).thenAnswer(
      (_) => Stream.value(
        VideoDetail(
          id: '',
          url: 'https://www.w3schools.com/html/mov_bbb.mp4',
          imageUrl: '',
          thumbnailUrl: '',
          gifUrl: '',
          createdAt: DateTime.now(),
          description: '',
          location: const LatLng(0, 0),
          userId: '',
          likeCount: 0,
          commentCount: 0,
          haveLiked: false,
          createdBy: Profile(
            id: 'abc',
            name: 'test',
          ),
        ),
      ),
    );
    when(() => repository.getVideoDetailStream('')).thenAnswer((_) => Future.value());
    when(() => repository.getVideoPlayerController('https://www.w3schools.com/html/mov_bbb.mp4'))
        .thenAnswer((invocation) => Future.value(
            VideoPlayerController.network('https://www.w3schools.com/html/mov_bbb.mp4')));
    when(() => repository.getComments('')).thenAnswer((invocation) => Future.value([]));

    test('Initial State', () {
      expect(VideoCubit(repository: repository).state is VideoInitial, true);
    });

    blocTest<VideoCubit, VideoState>(
      'initialize()',
      build: () => VideoCubit(repository: repository),
      act: (cubit) async {
        await cubit.initialize('');
      },
      expect: () => [
        isA<VideoLoading>(),
      ],
    );
  });
}
