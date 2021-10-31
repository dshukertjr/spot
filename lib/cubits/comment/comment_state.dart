part of 'comment_cubit.dart';

@immutable

/// Base state of Comments
abstract class CommentState {}

/// Initial State of CommentState
class CommentInitial extends CommentState {}

/// State where no comments were found
class CommentsEmpty extends CommentState {}

/// State where comments were found and have been loaded
class CommentsLoaded extends CommentState {
  /// State where comments were found and have been loaded
  CommentsLoaded(
    this.comments, {
    this.mentionSuggestions,
    this.isLoadingMentionSuggestions = false,
  });

  /// Comments that were loaded
  final List<Comment> comments;

  /// List of suggested mentions for when composing a comment
  final List<Profile>? mentionSuggestions;

  /// Whether or not the app is loading suggestions for mentions.
  final bool isLoadingMentionSuggestions;
}

/// State where something went wrong regarding comments
class CommentError extends CommentState {
  ///
  /// State where something went wrong regarding comments
  CommentError({required this.message});

  /// Error message to display to the user.
  final String message;
}
