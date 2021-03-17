import 'comment.dart';
import 'profile.dart';
import 'video.dart';

class Notification {
  Notification({
    this.comment,
    this.targetVideo,
    required this.profile,
    required this.createdAt,
  });

  final Comment? comment;
  final Video? targetVideo;
  final Profile profile;
  final DateTime createdAt;
}
