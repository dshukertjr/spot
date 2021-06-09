import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';

part 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  CommentCubit({
    required Repository repository,
    required String videoId,
  })  : _repository = repository,
        _videoId = videoId,
        super(CommentInitial());

  final Repository _repository;

  List<Comment> _comments = [];
  final String _videoId;

  Future<void> loadComments() async {
    try {
      _comments = await _repository.getComments(_videoId);
      emit(CommentsLoaded(_comments));
      final mentions = _comments
          .map((comment) => getUserIdsInComment(comment.text))
          .expand((mention) => mention)
          .toList();
      final profilesList = await Future.wait(mentions.map(_repository.getProfile).toList());
      final profiles = Map.fromEntries(
          profilesList.map((profile) => MapEntry<String, Profile>(profile!.id, profile)));
      _comments = _comments
          .map((comment) => comment.copyWith(
              text: replaceMentionsWithUserNames(profiles: profiles, comment: comment.text)))
          .toList();
      emit(CommentsLoaded(_comments));
    } catch (err) {
      emit(CommentError(message: 'Error opening comments of the video.'));
    }
  }

  Future<void> postComment(String text) async {
    try {
      final userId = _repository.userId;
      final user = await _repository.getProfile(userId!);
      final comment = Comment(
        id: 'new',
        text: text,
        createdAt: DateTime.now(),
        videoId: _videoId,
        user: user!,
      );
      _comments.insert(0, comment);
      emit(CommentsLoaded(_comments));
      final mentions = _repository.getMentionedProfiles(comment.text);
      final mentionReplacedText = replaceMentionsInAComment(comment: text, mentions: mentions);
      await _repository.comment(text: mentionReplacedText, videoId: _videoId, mentions: mentions);
    } catch (err) {
      emit(CommentError(message: 'Error commenting.'));
    }
  }

  Future<void> getMentionSuggestion(String comment) async {
    final mentionedUserName = getMentionedUserName(comment);
    if (mentionedUserName == null) {
      emit(CommentsLoaded(_comments));
      return;
    }
    emit(CommentsLoaded(_comments, isLoadingMentions: true));
    final mentionSuggestions = await _repository.getMentions(mentionedUserName);
    emit(CommentsLoaded(_comments, mentionSuggestions: mentionSuggestions));
  }

  /// Replaces mentioned user names with users' id in comment text
  @visibleForTesting
  String replaceMentionsInAComment({required String comment, required List<Profile> mentions}) {
    var mentionReplacedText = comment;
    for (final mention in mentions) {
      mentionReplacedText = mentionReplacedText.replaceAll('@${mention.name}', '@${mention.id}');
    }
    return mentionReplacedText;
  }

  /// Extracts the username to be searched within the database
  @visibleForTesting
  String? getMentionedUserName(String comment) {
    final mention = comment.split(' ').last;
    if (mention.isEmpty || mention[0] != '@') {
      return null;
    }
    final mentionedUserName = mention.substring(1);
    if (mentionedUserName.isEmpty) {
      return null;
    }
    return mentionedUserName;
  }

  @visibleForTesting
  List<String> getUserIdsInComment(String comment) {
    final regExp = RegExp(r'\b@[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b');
    final matches = regExp.allMatches(comment);
    return matches.map((match) => match.group(0)!).toList();
  }

  @visibleForTesting
  String replaceMentionsWithUserNames({
    required Map<String, Profile> profiles,
    required String comment,
  }) {
    final regExp = RegExp(r'\b@[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b');
    return comment.replaceAllMapped(regExp, (match) => profiles[match.group(0)!]!.name);
  }
}
