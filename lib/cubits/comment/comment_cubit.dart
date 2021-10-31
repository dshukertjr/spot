import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';

part 'comment_state.dart';

/// Cubit that takes care of anything related to comments.
class CommentCubit extends Cubit<CommentState> {
  /// Cubit that takes care of anything related to comments.
  CommentCubit({
    required Repository repository,
    required String videoId,
  })  : _repository = repository,
        _videoId = videoId,
        super(CommentInitial());

  final Repository _repository;
  final String _videoId;

  List<Comment> _comments = [];

  @visibleForTesting

  /// Listener that listens to list of comments emmited from repository
  StreamSubscription<List<Comment>>? commentsListener;

  @override
  Future<void> close() {
    commentsListener?.cancel();
    return super.close();
  }

  /// Loads comments of a video
  Future<void> loadComments() async {
    try {
      if (_comments.isNotEmpty) {
        return;
      }
      await _repository.getComments(_videoId);
      commentsListener = _repository.commentsStream.listen((comments) async {
        _comments = comments;
        if (_comments.isEmpty) {
          emit(CommentsEmpty());
          return;
        } else {
          emit(CommentsLoaded(_comments));
        }
      });
    } catch (err) {
      emit(CommentError(message: 'Error opening comments of the video.'));
    }
  }

  /// Posts a new comment on a video
  Future<void> postComment(String text) async {
    try {
      final userId = _repository.userId;
      await _repository.getProfileDetail(userId!);
      final profiles = await _repository.profileStream.first;
      final user = profiles[userId];
      final comment = Comment(
        id: 'new',
        text: text,
        createdAt: DateTime.now(),
        videoId: _videoId,
        user: user!,
      );
      _comments.insert(0, comment);
      emit(CommentsLoaded(_comments));
      final myUserId = _repository.userId;
      final profilesInComments = _comments
          .where((comment) => comment.user.id != myUserId)
          .map((comment) => comment.user)
          .toList();

      final mentions = _repository.getMentionedProfiles(
        commentText: comment.text,
        profilesInComments: profilesInComments,
      );
      final mentionReplacedText = _repository.replaceMentionsInAComment(
          comment: text, mentions: mentions);
      await _repository.postComment(
          text: mentionReplacedText, videoId: _videoId, mentions: mentions);
    } catch (err) {
      emit(CommentError(message: 'Error commenting.'));
    }
  }

  /// Called when mention suggestion has been tapped
  /// This method appends the selected mention at the end of the comment
  String createCommentWithMentionedProfile({
    required String commentText,
    required String profileName,
  }) {
    final lastSpaceIndex =
        commentText.lastIndexOf(' ') < 0 ? 0 : commentText.lastIndexOf(' ');
    if (lastSpaceIndex == 0) {
      return '@$profileName ';
    }
    return '${commentText.substring(0, lastSpaceIndex)} @$profileName ';
  }

  /// Called everytime comment is being edited
  /// Checks if there are any mentions in a comment and returns suggestion
  Future<void> getMentionSuggestion(String comment) async {
    final mentionedUserName = _repository.getMentionedUserName(comment);
    if (mentionedUserName == null) {
      emit(CommentsLoaded(_comments));
      return;
    } else if (mentionedUserName == '@') {
      final myUserId = _repository.userId;
      final usersInComments = _comments
          .where((comment) => comment.user.id != myUserId)
          .map((comment) => comment.user)
          .take(2)
          .toList();
      emit(CommentsLoaded(_comments, mentionSuggestions: usersInComments));
      return;
    }
    emit(CommentsLoaded(_comments, isLoadingMentionSuggestions: true));
    final mentionSuggestions = await _repository.getMentions(mentionedUserName);
    emit(CommentsLoaded(_comments, mentionSuggestions: mentionSuggestions));
  }
}
