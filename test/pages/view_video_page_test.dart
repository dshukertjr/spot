import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';

import '../helpers/helpers.dart';

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

    testWidgets('Does not show delete button when the video is by someone else', (tester) async {
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

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((widget) => widget is PopupMenuButton<VideoMenu>));

      await tester.pump();

      expect(find.text('Delete this video'), findsNothing);
    });

    testWidgets('Delete video button gets rendered when the video belongs to you', (tester) async {
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
              userId: 'myUserId',
              likeCount: 0,
              commentCount: 0,
              haveLiked: false,
              createdBy: Profile(id: 'myUserId', name: 'name'),
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
            userId: 'myUserId',
            likeCount: 0,
            commentCount: 0,
            haveLiked: false,
            createdBy: Profile(id: 'myUserId', name: 'name'),
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

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((widget) => widget is PopupMenuButton<VideoMenu>));

      await tester.pump();

      expect(find.text('Delete this video'), findsOneWidget);
    });

    testWidgets('like() is called when haveLiked is false', (tester) async {
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
              createdBy: Profile(id: 'otherUser', name: 'name'),
            ),
          ));

      when(() => repository.videoDetailStream).thenAnswer(
        (_) => Stream.fromIterable([
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
            createdBy: Profile(id: 'otherUser', name: 'name'),
          ),
        ]),
      );

      when(() => repository.getVideoPlayerController('https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer(
              (_) => Future.value(VideoPlayerController.file(File('test_resources/video.mp4'))));

      when(() => repository.like('aaa')).thenAnswer((invocation) => Future.value());
      when(() => repository.unlike('aaa')).thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) => VideoCubit(repository: repository)..initialize('aaa'),
          child: ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));

      await tester.pump();

      verify(() => repository.like('aaa')).called(1);
      verifyNever(() => repository.unlike('aaa'));
    });

    testWidgets('unlike() is called when haveLiked is true', (tester) async {
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
              haveLiked: true,
              createdBy: Profile(id: 'otherUser', name: 'name'),
            ),
          ));

      when(() => repository.videoDetailStream).thenAnswer(
        (_) => Stream.fromIterable([
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
            haveLiked: true,
            createdBy: Profile(id: 'otherUser', name: 'name'),
          ),
        ]),
      );

      when(() => repository.getVideoPlayerController('https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer(
              (_) => Future.value(VideoPlayerController.file(File('test_resources/video.mp4'))));

      when(() => repository.like('aaa')).thenAnswer((invocation) => Future.value());
      when(() => repository.unlike('aaa')).thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) => VideoCubit(repository: repository)..initialize('aaa'),
          child: ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      await tester.tap(find.byIcon(Icons.favorite));

      await tester.pump();

      verifyNever(() => repository.like('aaa'));
      verify(() => repository.unlike('aaa')).called(1);
    });

    testWidgets('Can view comments', (tester) async {
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

      when(() => repository.getComments('aaa')).thenAnswer((_) => Future.value([
            Comment(
              id: 'id',
              text: 'sample comment',
              createdAt: DateTime.now(),
              videoId: 'aaa',
              user: Profile(id: 'id', name: 'name'),
            ),
          ]));

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) => VideoCubit(repository: repository)..initialize('aaa'),
          child: ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      await tester.tap(find.byIcon(FeatherIcons.messageCircle));

      await tester.pump();

      expect(find.byType(CommentsOverlay), findsOneWidget);

      // Comments are loaded and displaed
      expect(
          find.byWidgetPredicate((widget) =>
              widget is RichText && widget.text.toPlainText().contains('sample comment')),
          findsOneWidget);
    });
  });
}
