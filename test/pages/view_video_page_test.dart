import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/comment/comment_cubit.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/login_page.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/utils/constants.dart';

import '../helpers/helpers.dart';
import '../test_resources/constants.dart';

class MockVideoCubit extends MockCubit<VideoState> implements VideoCubit {}

class MockCommentCubit extends MockCubit<CommentState> implements CommentCubit {
}

void main() {
  late final VideoDetail likedVideoDetail;
  setUpAll(() {
    HttpOverrides.global = null;
    likedVideoDetail = VideoDetail(
      id: 'aaa',
      url: 'url',
      imageUrl: 'imageUrl',
      thumbnailUrl: 'thumbnailUrl',
      gifUrl: 'gifUrl',
      createdAt: DateTime.now(),
      description: 'description',
      position: const LatLng(0, 0),
      userId: 'userId',
      isFollowing: false,
      likeCount: 0,
      commentCount: 0,
      haveLiked: false,
      createdBy: sampleProfile,
    );
    registerFallbackValue<VideoDetail>(likedVideoDetail);
  });
  group('VideoPage', () {
    testWidgets('Renders ViewVideoPage', (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.getVideoDetailStream('aaa'))
          .thenAnswer((_) => Future.value(
                VideoDetail(
                  id: 'aaa',
                  url: 'https://www.w3schools.com/html/mov_bbb.mp4',
                  imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                  description: 'description',
                  position: const LatLng(0, 0),
                  userId: 'otherUser',
                  likeCount: 0,
                  commentCount: 0,
                  haveLiked: false,
                  createdBy: sampleProfile,
                  isFollowing: false,
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
            position: const LatLng(0, 0),
            userId: 'otherUser',
            likeCount: 0,
            commentCount: 0,
            haveLiked: false,
            createdBy: sampleProfile,
            isFollowing: false,
          ),
        ),
      );

      when(() => repository.getVideoPlayerController(
              'https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer((_) => Future.value(
                BetterPlayerController(
                  const BetterPlayerConfiguration(),
                  betterPlayerDataSource: BetterPlayerDataSource(
                      BetterPlayerDataSourceType.network,
                      'https://www.w3schools.com/html/mov_bbb.mp4'),
                ),
              ));

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: const ViewVideoPage(),
        ),
        repository: repository,
      );

      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);
    });

    testWidgets('Does not show delete button when the video is by someone else',
        (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.getVideoDetailStream('aaa'))
          .thenAnswer((_) => Future.value(
                VideoDetail(
                  id: 'aaa',
                  url: 'https://www.w3schools.com/html/mov_bbb.mp4',
                  imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                  description: 'description',
                  position: const LatLng(0, 0),
                  userId: 'otherUser',
                  likeCount: 0,
                  commentCount: 0,
                  haveLiked: false,
                  createdBy: sampleProfile,
                  isFollowing: false,
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
            position: const LatLng(0, 0),
            userId: 'otherUser',
            likeCount: 0,
            commentCount: 0,
            haveLiked: false,
            createdBy: sampleProfile,
            isFollowing: false,
          ),
        ),
      );

      when(() => repository.getVideoPlayerController(
              'https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer((_) => Future.value(
                BetterPlayerController(
                  const BetterPlayerConfiguration(),
                  betterPlayerDataSource: BetterPlayerDataSource(
                      BetterPlayerDataSourceType.network,
                      'https://www.w3schools.com/html/mov_bbb.mp4'),
                ),
              ));

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: const ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      await tester.tap(find
          .byWidgetPredicate((widget) => widget is PopupMenuButton<VideoMenu>));

      await tester.pump();

      expect(find.text('Delete this video'), findsNothing);
    });

    testWidgets(
        'Delete video button gets rendered when the video belongs to you',
        (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.getVideoDetailStream('aaa'))
          .thenAnswer((_) => Future.value(
                VideoDetail(
                  id: 'aaa',
                  url: 'https://www.w3schools.com/html/mov_bbb.mp4',
                  imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                  description: 'description',
                  position: const LatLng(0, 0),
                  userId: 'myUserId',
                  likeCount: 0,
                  commentCount: 0,
                  haveLiked: false,
                  createdBy: sampleProfile,
                  isFollowing: false,
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
            position: const LatLng(0, 0),
            userId: 'myUserId',
            likeCount: 0,
            commentCount: 0,
            haveLiked: false,
            createdBy: sampleProfile,
            isFollowing: false,
          ),
        ),
      );

      when(() => repository.getVideoPlayerController(
              'https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer((_) => Future.value(
                BetterPlayerController(
                  const BetterPlayerConfiguration(),
                  betterPlayerDataSource: BetterPlayerDataSource(
                      BetterPlayerDataSourceType.network,
                      'https://www.w3schools.com/html/mov_bbb.mp4'),
                ),
              ));

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: const ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      await tester.tap(find
          .byWidgetPredicate((widget) => widget is PopupMenuButton<VideoMenu>));

      await tester.pump();

      expect(find.text('Delete this video'), findsOneWidget);
    });

    testWidgets('like() is called when haveLiked is false', (tester) async {
      final repository = MockRepository();

      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.myProfile).thenReturn(sampleProfile);
      when(() => repository.statusKnown).thenReturn(Completer()..complete());

      when(() => repository.getVideoDetailStream('aaa'))
          .thenAnswer((_) => Future.value(
                VideoDetail(
                  id: 'aaa',
                  url: 'https://www.w3schools.com/html/mov_bbb.mp4',
                  imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                  description: 'description',
                  position: const LatLng(0, 0),
                  userId: 'otherUser',
                  likeCount: 0,
                  commentCount: 0,
                  haveLiked: false,
                  createdBy: sampleProfile,
                  isFollowing: false,
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
            position: const LatLng(0, 0),
            userId: 'otherUser',
            likeCount: 0,
            commentCount: 0,
            haveLiked: false,
            createdBy: otherProfile,
            isFollowing: false,
          ),
        ]),
      );

      when(() => repository.getVideoPlayerController(
              'https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer((_) => Future.value(
                BetterPlayerController(
                  const BetterPlayerConfiguration(),
                  betterPlayerDataSource: BetterPlayerDataSource(
                      BetterPlayerDataSourceType.network,
                      'https://www.w3schools.com/html/mov_bbb.mp4'),
                ),
              ));

      when(() => repository.like(any<VideoDetail>()))
          .thenAnswer((invocation) => Future.value());
      when(() => repository.unlike(any<VideoDetail>()))
          .thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: const ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));

      await tester.pump();

      verify(() => repository.like(any<VideoDetail>())).called(1);
      verifyNever(() => repository.unlike(any<VideoDetail>()));
    });

    testWidgets(
        'LoginPage is opened when like button is pressed and not signed in',
        (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn(null);
      when(() => repository.hasAgreedToTermsOfService)
          .thenAnswer((invocation) async => true);
      when(() => repository.statusKnown).thenReturn(Completer()..complete());
      when(() => repository.getVideoDetailStream('aaa'))
          .thenAnswer((_) => Future.value(
                VideoDetail(
                  id: 'aaa',
                  url: 'https://www.w3schools.com/html/mov_bbb.mp4',
                  imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                  description: 'description',
                  position: const LatLng(0, 0),
                  userId: 'otherUser',
                  likeCount: 0,
                  commentCount: 0,
                  haveLiked: false,
                  createdBy: otherProfile,
                  isFollowing: false,
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
            position: const LatLng(0, 0),
            userId: 'otherUser',
            likeCount: 0,
            commentCount: 0,
            haveLiked: false,
            createdBy: otherProfile,
            isFollowing: false,
          ),
        ]),
      );

      when(() => repository.getVideoPlayerController(
              'https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer((_) => Future.value(
                BetterPlayerController(
                  const BetterPlayerConfiguration(),
                  betterPlayerDataSource: BetterPlayerDataSource(
                      BetterPlayerDataSourceType.network,
                      'https://www.w3schools.com/html/mov_bbb.mp4'),
                ),
              ));

      when(() => repository.like(likedVideoDetail))
          .thenAnswer((invocation) => Future.value());
      when(() => repository.unlike(likedVideoDetail))
          .thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: const ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));

      await tester.pumpAndSettle();

      verifyNever(() => repository.like(likedVideoDetail));
      verifyNever(() => repository.unlike(likedVideoDetail));
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('unlike() is called when haveLiked is true', (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.myProfile).thenReturn(sampleProfile);
      when(() => repository.statusKnown).thenReturn(Completer()..complete());
      when(() => repository.getVideoDetailStream(likedVideoDetail.id))
          .thenAnswer((_) => Future.value(
                VideoDetail(
                  id: 'aaa',
                  url: 'https://www.w3schools.com/html/mov_bbb.mp4',
                  imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                  description: 'description',
                  position: const LatLng(0, 0),
                  userId: 'otherUser',
                  likeCount: 0,
                  commentCount: 0,
                  haveLiked: true,
                  createdBy: otherProfile,
                  isFollowing: false,
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
            position: const LatLng(0, 0),
            userId: 'otherUser',
            likeCount: 0,
            commentCount: 0,
            haveLiked: true,
            createdBy: otherProfile,
            isFollowing: false,
          ),
        ]),
      );

      when(() => repository.getVideoPlayerController(
              'https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer((_) => Future.value(
                BetterPlayerController(
                  const BetterPlayerConfiguration(),
                  betterPlayerDataSource: BetterPlayerDataSource(
                      BetterPlayerDataSourceType.network,
                      'https://www.w3schools.com/html/mov_bbb.mp4'),
                ),
              ));

      when(() => repository.like(any<VideoDetail>()))
          .thenAnswer((invocation) => Future.value());
      when(() => repository.unlike(any<VideoDetail>()))
          .thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) => VideoCubit(repository: repository)
            ..initialize(likedVideoDetail.id),
          child: const ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      await tester.tap(find.byIcon(Icons.favorite));

      await tester.pump();

      verifyNever(() => repository.like(any<VideoDetail>()));
      verify(() => repository.unlike(any<VideoDetail>())).called(1);
    });

    testWidgets('Can view comments', (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.getVideoDetailStream('aaa'))
          .thenAnswer((_) => Future.value(
                VideoDetail(
                  id: 'aaa',
                  url: 'https://www.w3schools.com/html/mov_bbb.mp4',
                  imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
                  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                  description: 'description',
                  position: const LatLng(0, 0),
                  userId: 'otherUser',
                  likeCount: 0,
                  commentCount: 0,
                  haveLiked: false,
                  createdBy: sampleProfile,
                  isFollowing: false,
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
            position: const LatLng(0, 0),
            userId: 'otherUser',
            likeCount: 0,
            commentCount: 0,
            haveLiked: false,
            createdBy: sampleProfile,
            isFollowing: false,
          ),
        ),
      );

      when(() => repository.getVideoPlayerController(
              'https://www.w3schools.com/html/mov_bbb.mp4'))
          .thenAnswer((_) => Future.value(
                BetterPlayerController(
                  const BetterPlayerConfiguration(),
                  betterPlayerDataSource: BetterPlayerDataSource(
                      BetterPlayerDataSourceType.network,
                      'https://www.w3schools.com/html/mov_bbb.mp4'),
                ),
              ));

      when(() => repository.getComments('aaa'))
          .thenAnswer((_) => Future.value());

      when(() => repository.commentsStream)
          .thenAnswer((invocation) => Stream.value([
                Comment(
                  id: 'id',
                  text: 'sample comment',
                  createdAt: DateTime.now(),
                  videoId: 'aaa',
                  user: sampleProfile,
                ),
              ]));

      when(() => repository.getUserIdsInComment(any<String>()))
          .thenAnswer((invocation) => []);

      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<VideoCubit>(
              create: (BuildContext context) =>
                  VideoCubit(repository: repository)..initialize('aaa'),
            ),
            BlocProvider<CommentCubit>(
              create: (BuildContext context) =>
                  CommentCubit(repository: repository, videoId: 'aaa')
                    ..loadComments(),
            ),
          ],
          child: const ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      await tester.tap(find.byIcon(FeatherIcons.messageCircle));

      await tester.pump();

      expect(find.byType(CommentsOverlay), findsOneWidget);

      await tester.pump();

      // Comments are loaded and displaed
      expect(
          find.byWidgetPredicate((widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('sample comment')),
          findsOneWidget);
    });
  });

  group('Mentions', () {
    setUpAll(() {
      HttpOverrides.global = null;

      registerFallbackValue<String>('');

      registerFallbackValue<CommentState>(CommentInitial());
    });

    testWidgets('Mentions are being displayed properly', (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('myUserId');

      when(() => repository.getMentionedUserName('')).thenReturn(null);
      when(() => repository.getMentionedUserName('@')).thenReturn('@');

      when(() => repository.getComments('aaa')).thenAnswer((_) async => null);

      when(() => repository.commentsStream)
          .thenAnswer((_) => Stream.fromIterable([
                [
                  Comment(
                    id: 'id',
                    text: 'text',
                    createdAt: DateTime.now(),
                    videoId: 'aaa',
                    user: Profile(id: 'abc', name: 'Tyler'),
                  ),
                ]
              ]));

      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<CommentCubit>(
              create: (BuildContext context) => CommentCubit(
                repository: repository,
                videoId: 'aaa',
              )..loadComments(),
            ),
          ],
          child: Material(child: CommentsOverlay(onClose: () {})),
        ),
        repository: repository,
      );

      await tester.pump();

      /// Finds the user name from the comment
      expect(find.text('Tyler'), findsOneWidget);
      expect(find.byWidget(preloader), findsNothing);

      /// Type `@` to see the suggestions
      await tester.enterText(find.byType(TextFormField), '@');

      await tester.pump();

      /// Find both the comment and suggestion
      expect(find.text('Tyler'), findsNWidgets(2));

      /// Tap on the suggestion
      await tester.tap(find.byType(ListTile));

      await tester.pump();

      /// After tapping on a suggestion, the textField
      /// value is overridden to `@[user_name]`
      final value = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller!
          .text;
      expect(value, '@Tyler ');
    });
  });
}
