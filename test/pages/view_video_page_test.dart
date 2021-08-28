import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/pages/login_page.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/cubits/comment/comment_cubit.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:video_player/video_player.dart';

import '../helpers/helpers.dart';
import '../test_resources/constants.dart';

class MockVideoCubit extends MockCubit<VideoState> implements VideoCubit {}

class MockCommentCubit extends MockCubit<CommentState> implements CommentCubit {
}

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
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
                  location: const LatLng(0, 0),
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
            location: const LatLng(0, 0),
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
              VideoPlayerController.file(File('test_resources/video.mp4'))));

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: ViewVideoPage(),
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
                  location: const LatLng(0, 0),
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
            location: const LatLng(0, 0),
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
              VideoPlayerController.file(File('test_resources/video.mp4'))));

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: ViewVideoPage(),
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
                  location: const LatLng(0, 0),
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
            location: const LatLng(0, 0),
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
              VideoPlayerController.file(File('test_resources/video.mp4'))));

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: ViewVideoPage(),
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
      final statusKnown = Completer<void>();
      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.myProfile).thenReturn(sampleProfile);
      when(() => repository.statusKnown).thenReturn(statusKnown);
      statusKnown.complete();
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
                  location: const LatLng(0, 0),
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
            location: const LatLng(0, 0),
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
              VideoPlayerController.file(File('test_resources/video.mp4'))));

      when(() => repository.like('aaa'))
          .thenAnswer((invocation) => Future.value());
      when(() => repository.unlike('aaa'))
          .thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
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

    testWidgets(
        'LoginPage is opened when like button is pressed and not signed in',
        (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn(null);
      when(() => repository.hasAgreedToTermsOfService)
          .thenAnswer((invocation) async => true);
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
                  location: const LatLng(0, 0),
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
            location: const LatLng(0, 0),
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
              VideoPlayerController.file(File('test_resources/video.mp4'))));

      when(() => repository.like('aaa'))
          .thenAnswer((invocation) => Future.value());
      when(() => repository.unlike('aaa'))
          .thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
          child: ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(VideoScreen), findsOneWidget);

      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));

      await tester.pumpAndSettle();

      verifyNever(() => repository.like('aaa'));
      verifyNever(() => repository.unlike('aaa'));
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('unlike() is called when haveLiked is true', (tester) async {
      final repository = MockRepository();
      final statusKnown = Completer<void>();
      when(() => repository.userId).thenReturn('myUserId');
      when(() => repository.myProfile).thenReturn(sampleProfile);
      when(() => repository.statusKnown).thenReturn(statusKnown);
      statusKnown.complete();
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
                  location: const LatLng(0, 0),
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
            location: const LatLng(0, 0),
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
              VideoPlayerController.file(File('test_resources/video.mp4'))));

      when(() => repository.like('aaa'))
          .thenAnswer((invocation) => Future.value());
      when(() => repository.unlike('aaa'))
          .thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (BuildContext context) =>
              VideoCubit(repository: repository)..initialize('aaa'),
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
                  location: const LatLng(0, 0),
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
            location: const LatLng(0, 0),
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
              VideoPlayerController.file(File('test_resources/video.mp4'))));

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
          child: ViewVideoPage(),
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

      registerFallbackValue<VideoState>(VideoPlaying(
        videoDetail: VideoDetail(
          id: 'id',
          url: 'url',
          imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
          thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
          gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
          createdAt: DateTime.now(),
          description: 'description',
          location: const LatLng(0, 0),
          userId: 'userId',
          likeCount: 1,
          commentCount: 1,
          haveLiked: false,
          createdBy: sampleProfile,
          isFollowing: false,
        ),
      ));
      registerFallbackValue<CommentState>(CommentInitial());
    });

    testWidgets('Mentions are being displayed properly', (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('myUserId');
      final mockVideoCubit = MockVideoCubit();
      final mockCommentCubit = MockCommentCubit();

      when(() => mockCommentCubit.getMentionSuggestion(any<String>()))
          .thenAnswer((invocation) => Future.value());

      when(mockCommentCubit.loadComments)
          .thenAnswer((invocation) => Future.value());

      when(() => mockCommentCubit.createCommentWithMentionedProfile(
            commentText: any<String>(named: 'commentText'),
            profileName: any<String>(named: 'profileName'),
          )).thenReturn('@Tyler ');

      whenListen(
        mockVideoCubit,
        Stream.fromIterable([
          VideoPlaying(
            videoDetail: VideoDetail(
              id: 'id',
              url: 'url',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now(),
              description: 'description',
              location: const LatLng(0, 0),
              userId: 'userId',
              likeCount: 1,
              commentCount: 1,
              haveLiked: false,
              createdBy: sampleProfile,
              isFollowing: false,
            ),
          ),
          VideoPlaying(
            videoDetail: VideoDetail(
              id: 'id',
              url: 'url',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now(),
              description: 'description',
              location: const LatLng(0, 0),
              userId: 'userId',
              likeCount: 1,
              commentCount: 1,
              haveLiked: false,
              createdBy: sampleProfile,
              isFollowing: false,
            ),
          ),
        ]),
        initialState: VideoPlaying(
          videoDetail: VideoDetail(
            id: 'id',
            url: 'url',
            imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
            thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
            gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
            createdAt: DateTime.now(),
            description: 'description',
            location: const LatLng(0, 0),
            userId: 'userId',
            likeCount: 1,
            commentCount: 1,
            haveLiked: false,
            createdBy: sampleProfile,
            isFollowing: false,
          ),
        ),
      );

      whenListen(
        mockCommentCubit,
        Stream.fromIterable([
          CommentsLoaded(
            [
              Comment(
                id: 'id',
                text: 'text',
                createdAt: DateTime.now(),
                videoId: 'videoId',
                user: sampleProfile,
              )
            ],
            mentionSuggestions: [],
            isLoadingMentions: true,
          ),
          CommentsLoaded(
            [
              Comment(
                id: 'id',
                text: 'text',
                createdAt: DateTime.now(),
                videoId: 'videoId',
                user: sampleProfile,
              )
            ],
            mentionSuggestions: [
              Profile(id: 'aaa', name: 'Tyler', isFollowing: false),
              Profile(id: 'bbb', name: 'Takahiro', isFollowing: false),
            ],
            isLoadingMentions: false,
          ),
        ]),
      );

      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<VideoCubit>(
                create: (BuildContext context) => mockVideoCubit),
            BlocProvider<CommentCubit>(
                create: (BuildContext context) => mockCommentCubit),
          ],
          child: ViewVideoPage(),
        ),
        repository: repository,
      );

      await tester.tap(find.byIcon(FeatherIcons.messageCircle));
      await tester.pump();

      /// suggestions are being displayed
      expect(find.text('Tyler'), findsOneWidget);
      expect(find.byWidget(preloader), findsOneWidget);

      await tester.tap(find.text('Tyler'));

      await tester.pump();

      final value = tester
          .widget<TextFormField>(find.byType(TextFormField))
          .controller!
          .text;
      expect(value, '@Tyler ');
    });
  });
}
