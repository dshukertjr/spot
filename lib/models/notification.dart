import 'package:flutter/material.dart';

enum NotificationType {
  like,
  comment,
  follow,
  other,
}

extension NotificationTypeCreate on NotificationType {
  static NotificationType fromString(String val) {
    switch (val) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      default:
        return NotificationType.other;
    }
  }
}

class AppNotification {
  AppNotification({
    required this.type,
    this.commentText,
    this.targetVideoId,
    this.targetVideoThumbnail,
    this.actionUid,
    this.actionUserName,
    this.actionUserImageUrl,
    required this.createdAt,
    required this.isNew,
  }) : assert(
          (type == NotificationType.like && targetVideoId != null) ||
              (type == NotificationType.comment && commentText != null) ||
              type == NotificationType.follow ||
              type == NotificationType.other,
        );

  final NotificationType type;
  final String? commentText;
  final String? targetVideoId;
  final String? targetVideoThumbnail;
  final String? actionUid;
  final String? actionUserName;
  final String? actionUserImageUrl;
  final DateTime createdAt;
  final bool isNew;

  static List<AppNotification> fromData(
    List<dynamic> data, {
    @required DateTime? createdAtOfLastSeenNotification,
  }) {
    return data.map<AppNotification>(
      (row) {
        final createdAt = DateTime.parse(row['created_at'] as String);
        var isNew = false;
        if (createdAtOfLastSeenNotification == null ||
            createdAt.isAfter(createdAtOfLastSeenNotification)) {
          isNew = true;
        }
        return AppNotification(
          type: NotificationTypeCreate.fromString(row['type'] as String),
          commentText: row['comment_text'] as String?,
          targetVideoId: row['video_id'] as String?,
          targetVideoThumbnail: row['video_thumbnail_url'] as String?,
          actionUid: row['action_user_id'] as String?,
          actionUserName: row['action_user_name'] as String?,
          actionUserImageUrl: row['action_user_image_url'] as String?,
          createdAt: createdAt,
          isNew: isNew,
        );
      },
    ).toList();
  }

  AppNotification copyWith({
    NotificationType? type,
    String? commentText,
    String? targetVideoId,
    String? targetVideoThumbnail,
    String? actionUid,
    String? actionUserName,
    String? actionUserImageUrl,
    DateTime? createdAt,
    bool? isNew,
  }) {
    return AppNotification(
      type: type ?? this.type,
      commentText: commentText ?? this.commentText,
      targetVideoId: targetVideoId ?? this.targetVideoId,
      targetVideoThumbnail: targetVideoThumbnail ?? this.targetVideoThumbnail,
      actionUid: actionUid ?? this.actionUid,
      actionUserName: actionUserName ?? this.actionUserName,
      actionUserImageUrl: actionUserImageUrl ?? this.actionUserImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isNew: isNew ?? this.isNew,
    );
  }
}
