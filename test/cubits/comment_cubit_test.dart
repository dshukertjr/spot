import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/comment/comment_cubit.dart';
import 'package:spot/models/profile.dart';

import '../helpers/pump_app.dart';

void main() {
  group('Basic', () {
    final repository = MockRepository();
    setUp(() {
      when(() => repository.getComments('')).thenAnswer((invocation) => Future.value([]));
    });
    testWidgets('comment cubit ...', (tester) async {});
  });

  group('mentions', () {
    final repository = MockRepository();
    final commentCubit = CommentCubit(repository: repository, videoId: 'abc');
    group('replaceMentionsInAComment', () {
      test('without mention', () {
        final comment = '@test';
        final replacedComment = commentCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [],
        );
        expect(replacedComment, '@test');
      });

      test('user mentioned at the beginning', () {
        final comment = '@test';
        final replacedComment = commentCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
          ],
        );
        expect(replacedComment, '@aaa');
      });
      test('user mentioned multiple times', () {
        final comment = '@test @test';
        final replacedComment = commentCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
          ],
        );
        expect(replacedComment, '@aaa @aaa');
      });
      test('multiple user mentions', () {
        final comment = '@test @some';
        final replacedComment = commentCubit.replaceMentionsInAComment(
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
        final replacedComment = commentCubit.replaceMentionsInAComment(
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
        final replacedComment = commentCubit.replaceMentionsInAComment(
          comment: comment,
          mentions: [
            Profile(id: 'aaa', name: 'test'),
          ],
        );
        expect(replacedComment, 'some comment @aaa more words');
      });

      test('multiple user mentions', () {
        final comment = 'some comment @test';
        final replacedComment = commentCubit.replaceMentionsInAComment(
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
        final mentionedUserName = commentCubit.getMentionedUserName(comment);
        expect(mentionedUserName, 'test');
      });
      test('username is at the end of comment', () {
        final comment = 'something @test';
        final mentionedUserName = commentCubit.getMentionedUserName(comment);
        expect(mentionedUserName, 'test');
      });
      test('There are no @ sign in the comment', () {
        final comment = 'something test';
        final mentionedUserName = commentCubit.getMentionedUserName(comment);
        expect(mentionedUserName, isNull);
      });
      test('@mention is not the last word in the comment', () {
        final comment = 'something @test another';
        final mentionedUserName = commentCubit.getMentionedUserName(comment);
        expect(mentionedUserName, isNull);
      });
      test('There are multiple @ sign in the comment', () {
        final comment = 'something @test @some';
        final mentionedUserName = commentCubit.getMentionedUserName(comment);
        expect(mentionedUserName, 'some');
      });
      test('createCommentWithMentionedProfile where the comment only has mentions', () {
        final commentText = '@som';
        final profileName = 'some';
        final replacedComment = commentCubit.createCommentWithMentionedProfile(
          commentText: commentText,
          profileName: profileName,
        );
        expect(replacedComment, '@some ');
      });
      test('createCommentWithMentionedProfile where the comment only has mentions', () {
        final commentText = 'another @som';
        final profileName = 'some';
        final replacedComment = commentCubit.createCommentWithMentionedProfile(
          commentText: commentText,
          profileName: profileName,
        );
        expect(replacedComment, 'another @some ');
      });
      test('createCommentWithMentionedProfile where the comment only has mentions', () {
        final commentText = '@another @som';
        final profileName = 'some';
        final replacedComment = commentCubit.createCommentWithMentionedProfile(
          commentText: commentText,
          profileName: profileName,
        );
        expect(replacedComment, '@another @some ');
      });
    });
  });
}
