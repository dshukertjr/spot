import 'comment.dart';
import 'profile.dart';
import 'video.dart';

enum NotificationType {
  like,
  comment,
  follow,
  other,
}

class AppNotification {
  AppNotification({
    required this.type,
    this.comment,
    this.targetVideoId,
    required this.profile,
    required this.createdAt,
  }) : assert(
          (type == NotificationType.like && targetVideoId != null) ||
              (type == NotificationType.comment && comment != null) ||
              type == NotificationType.follow ||
              type == NotificationType.other,
        );

  final NotificationType type;
  final Comment? comment;
  final String? targetVideoId;
  final Profile profile;
  final DateTime createdAt;
}
