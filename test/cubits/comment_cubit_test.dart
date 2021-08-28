import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/comment/comment_cubit.dart';
import 'package:spot/models/comment.dart';

import '../helpers/pump_app.dart';
import '../test_resources/constants.dart';

void main() {
  group('Basic', () {
    final repository = MockRepository();
    final commentCubit = CommentCubit(repository: repository, videoId: 'abc');
    test('CommentCubit Emits CommentsLoaded', () {
      when(() => repository.getComments('abc'))
          .thenAnswer((invocation) => Future.value());
      when(() => repository.commentsStream)
          .thenAnswer((invocation) => Stream.fromIterable([
                [],
                [
                  Comment(
                    id: 'id',
                    text: 'This is a sample comment',
                    createdAt: DateTime.now(),
                    videoId: 'aaa',
                    user: sampleProfile,
                  )
                ],
              ]));
      when(() => repository.getUserIdsInComment(any<String>())).thenReturn([]);

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
    });
  });

  group('mentions', () {
    final repository = MockRepository();
    final commentCubit = CommentCubit(repository: repository, videoId: 'abc');

    group('createCommentWithMentionedProfile', () {
      test(
          'createCommentWithMentionedProfile where the comment only has mentions',
          () {
        final commentText = '@som';
        final profileName = 'some';
        final replacedComment = commentCubit.createCommentWithMentionedProfile(
          commentText: commentText,
          profileName: profileName,
        );
        expect(replacedComment, '@some ');
      });
      test(
          'createCommentWithMentionedProfile where the comment only has mentions',
          () {
        final commentText = 'another @som';
        final profileName = 'some';
        final replacedComment = commentCubit.createCommentWithMentionedProfile(
          commentText: commentText,
          profileName: profileName,
        );
        expect(replacedComment, 'another @some ');
      });
      test(
          'createCommentWithMentionedProfile where the comment only has mentions',
          () {
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
