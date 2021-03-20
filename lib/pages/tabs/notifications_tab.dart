import 'package:flutter/material.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/notification.dart';

import '../../models/profile.dart';
import '../../models/video.dart';
import '../../models/video.dart';

class NotificationsTab extends StatelessWidget {
  final notifications = [
    AppNotification(
      type: NotificationType.like,
      profile: Profile(
        id: 'aaa',
        name: 'O\'niel',
        imageUrl:
            'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      ),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      targetVideoId: 'aaa',
    ),
    AppNotification(
      type: NotificationType.comment,
      profile: Profile(
        id: 'aaa',
        name: 'O\'niel',
        imageUrl:
            'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      ),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      comment: Comment(
        id: '',
        text: 'This is amazing',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        videoId: '',
      ),
    ),
    AppNotification(
      type: NotificationType.follow,
      profile: Profile(
        id: 'aaa',
        name: 'O\'niel',
        imageUrl:
            'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      ),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

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
        return '@${_notification.profile.name} liked your video"';
      case NotificationType.comment:
        return '@${_notification.profile.name} commented "${_notification.comment!.text}"';
      case NotificationType.follow:
        return '@${_notification.profile.name} started following you"';
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
