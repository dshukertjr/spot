import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:video_player/video_player.dart';

import '../helpers/helpers.dart';

class MockVideoCubit extends MockCubit<VideoState> implements VideoCubit {}

class FakeVideoState extends Fake implements VideoState {}

void main() {
  setUpAll(() => HttpOverrides.global = null);
  group('VideoPage', () {
    testWidgets('Renders ViewVideoPage', (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.getVideoDetailStream('aaa')).thenAnswer((_) => Future.value(
            VideoDetail(
              id: 'aaa',
              url: 'https://www.w3schools.com/html/mov_bbb.mp4',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              description: 'description',
              location: const LatLng(0, 0),
              userId: 'otherUser',
              likeCount: 0,
              commentCount: 0,
              haveLiked: false,
              createdBy: Profile(id: 'aaa', name: 'name'),
            ),
          ));

      when(() => repository.videoDetailStream).thenAnswer(
        (_) => Stream.value(
          VideoDetail(
            id: 'aaa',
            url: 'https://www.w3schools.com/html/mov_bbb.mp4',
            imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
            thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
            gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            description: 'description',
            location: const LatLng(0, 0),
            userId: 'otherUser',
            likeCount: 0,
            commentCount: 0,
            haveLiked: false,
            createdBy: Profile(id: 'aaa', name: 'name'),
          ),
        ),
      );

      when(() => repository.getVideoPlayerController('https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer(
              (_) => Future.value(VideoPlayerController.file(File('test_resources/video.mp4'))));

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) => VideoCubit(repository: repository)..initialize('aaa'),
          child: ViewVideoPage(),
        ),
        repository: repository,
      );

      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);
    });
  });
}
