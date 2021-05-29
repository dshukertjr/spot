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

  group('mentions', () {
    final repository = MockRepository();
    final videoCubit = VideoCubit(repository: repository);
    group('replaceMentionsInAComment', () {
      test('without mention', () {
        final comment = '@test';
        final replacedComment = videoCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [],
        );
        expect(replacedComment, '@test');
      });

      test('user mentioned at the beginning', () {
        final comment = '@test';
        final replacedComment = videoCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
          ],
        );
        expect(replacedComment, '@aaa');
      });
      test('user mentioned multiple times', () {
        final comment = '@test @test';
        final replacedComment = videoCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
          ],
        );
        expect(replacedComment, '@aaa @aaa');
      });
      test('multiple user mentions', () {
        final comment = '@test @some';
        final replacedComment = videoCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
            Profile(id: 'bbb', name: 'some'),
          ],
        );
        expect(replacedComment, '@aaa @bbb');
      });
      test('there can be multiple mentions', () {
        final comment = '@test @some';
        final replacedComment = videoCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
            Profile(id: 'bbb', name: 'some'),
          ],
        );
        expect(replacedComment, '@aaa @bbb');
      });

      test('mention can be in a sentence', () {
        final comment = 'some comment @test more words';
        final replacedComment = videoCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
          ],
        );
        expect(replacedComment, 'some comment @aaa more words');
      });

      test('multiple user mentions', () {
        final comment = 'some comment @test';
        final replacedComment = videoCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
          ],
        );
        expect(replacedComment, 'some comment @aaa');
      });
    });
    group('getMentionedUserName', () {
      test('username is the only thing within the comment', () {
        final comment = '@test';
        final mentionedUserName = videoCubit.getMentionedUserName(comment);
        expect(mentionedUserName, 'test');
      });
      test('username is at the end of comment', () {
        final comment = 'something @test';
        final mentionedUserName = videoCubit.getMentionedUserName(comment);
        expect(mentionedUserName, 'test');
      });
      test('There are no @ sign in the comment', () {
        final comment = 'something test';
        final mentionedUserName = videoCubit.getMentionedUserName(comment);
        expect(mentionedUserName, isNull);
      });
      test('@mention is not the last word in the comment', () {
        final comment = 'something @test another';
        final mentionedUserName = videoCubit.getMentionedUserName(comment);
        expect(mentionedUserName, isNull);
      });
      test('There are multiple @ sign in the comment', () {
        final comment = 'something @test @some';
        final mentionedUserName = videoCubit.getMentionedUserName(comment);
        expect(mentionedUserName, 'some');
      });
    });
  });
}
