part of 'comment_cubit.dart';

@immutable
abstract class CommentState {}

class CommentInitial extends CommentState {}

class CommentsEmpty extends CommentState {}

class CommentsLoaded extends CommentState {
  CommentsLoaded(
    this.comments, {
    this.mentionSuggestions,
    this.isLoadingMentions = false,
  });
  final List<Comment> comments;
  final List<Profile>? mentionSuggestions;
  final bool isLoadingMentions;
}

class CommentError extends CommentState {
  CommentError({required this.message});
  final String message;
}
