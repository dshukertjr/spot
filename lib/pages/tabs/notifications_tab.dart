import 'package:flutter/material.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/models/notification.dart';

class NotificationsTab extends StatelessWidget {
  final notifications = [];

  @override
  Widget build(BuildContext context) {
    final safeAreaPadding = MediaQuery.of(context).padding;
    return ListView.separated(
      padding: EdgeInsets.only(
        top: 16 + safeAreaPadding.top,
        right: 16 + safeAreaPadding.right,
        bottom: 16 + safeAreaPadding.bottom,
        left: 16 + safeAreaPadding.left,
      ),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        return _NotificationCell(
          notification: notifications[index],
        );
      },
    );
  }
}

class _NotificationCell extends StatelessWidget {
  const _NotificationCell({
    Key? key,
    required AppNotification notification,
  })   : _notification = notification,
        super(key: key);

  final AppNotification _notification;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ProfileImage(),
        const SizedBox(width: 16),
        Expanded(
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(text: _notificationText),
                TextSpan(
                  text: ' 1h',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 24,
          height: 24,
          child: Image.asset(_notificationIconPath),
        ),
      ],
    );
  }

  String get _notificationText {
    switch (_notification.type) {
      case NotificationType.like:
        return '@${_notification.actionUserName} liked your video"';
      case NotificationType.comment:
        return '@${_notification.actionUserName} commented "${_notification.commentText}"';
      case NotificationType.follow:
        return '@${_notification.actionUserName} started following you"';
      case NotificationType.other:
        return '';
    }
  }

  String get _notificationIconPath {
    switch (_notification.type) {
      case NotificationType.like:
        return 'assets/images/like.png';
      case NotificationType.comment:
        return 'assets/images/comment.png';
      case NotificationType.follow:
        return 'assets/images/follower.png';
      case NotificationType.other:
        return 'assets/images/like.png';
    }
  }
}
