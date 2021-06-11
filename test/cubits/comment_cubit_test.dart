import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/comment/comment_cubit.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/profile.dart';

import '../helpers/pump_app.dart';

void main() {
  group('Basic', () {
    final repository = MockRepository();
    final commentCubit = CommentCubit(repository: repository, videoId: 'abc');
    test('CommentCubit Emits CommentsLoaded', () {
      when(() => repository.getComments('abc')).thenAnswer((invocation) => Future.value());
      when(() => repository.commentsStream).thenAnswer((invocation) => Stream.fromIterable([
            [],
            [
              Comment(
                id: 'id',
                text: 'This is a sample comment',
                createdAt: DateTime.now(),
                videoId: 'aaa',
                user: Profile(
                  id: 'abc',
                  name: 'Tyler',
                ),
              )
            ],
          ]));

      expectLater(
        commentCubit.stream,
        emitsInOrder(
          [
            isA<CommentsEmpty>(),
            isA<CommentsLoaded>(),
          ],
        ),
      );
      commentCubit.loadComments();

      // commentCubit.stream.listen(expectAsync1<void, CommentState>((state) {
      //   expect(state is CommentsLoaded, true);
      // }));
    });
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
      test('getUserIdsInComment with 0 user id', () {
        final comment = 'some random text';
        final userIds = commentCubit.getUserIdsInComment(comment);
        expect(userIds, []);
      });
      test('getUserIdsInComment with 1 user id at the beginning', () {
        final comment = '@b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay';
        final userIds = commentCubit.getUserIdsInComment(comment);
        expect(userIds, ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2']);
      });
      test('getUserIdsInComment with 1 user id', () {
        final comment = 'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay';
        final userIds = commentCubit.getUserIdsInComment(comment);
        expect(userIds, ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2']);
      });
      test('getUserIdsInComment with 2 user id', () {
        final comment =
            'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2';
        final userIds = commentCubit.getUserIdsInComment(comment);
        expect(userIds,
            ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2', 'aaabac1a-8d4b-4361-99cc-a1d274d1c4d2']);
      });
      test('getUserIdsInComment with 2 user id with the same id', () {
        final comment =
            'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2';
        final userIds = commentCubit.getUserIdsInComment(comment);
        expect(userIds,
            ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2', 'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2']);
      });
      test('replaceMentionsWithUserNames with two profiles', () {
        final comment =
            'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2';
        final profiles = <String, Profile>{
          'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2': Profile(
            id: 'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2',
            name: 'Tyler',
          ),
          'aaabac1a-8d4b-4361-99cc-a1d274d1c4d2': Profile(
            id: 'aaabac1a-8d4b-4361-99cc-a1d274d1c4d2',
            name: 'Sam',
          ),
        };
        final updatedComment =
            commentCubit.replaceMentionsWithUserNames(comment: comment, profiles: profiles);
        expect(updatedComment, 'something random @Tyler yay @Sam');
      });
      test('replaceMentionsWithUserNames with two userIds of the same user', () {
        final comment =
            'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2';
        final profiles = <String, Profile>{
          'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2': Profile(
            id: 'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2',
            name: 'Tyler',
          ),
        };
        final updatedComment =
            commentCubit.replaceMentionsWithUserNames(comment: comment, profiles: profiles);
        expect(updatedComment, 'something random @Tyler yay @Tyler');
      });
      test(
          'replaceMentionsWithUserNames where the profile was not found should not change the comment',
          () {
        final comment = 'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay';
        final profiles = <String, Profile>{};
        final updatedComment =
            commentCubit.replaceMentionsWithUserNames(comment: comment, profiles: profiles);
        expect(updatedComment, 'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay');
      });
    });
  });
}
