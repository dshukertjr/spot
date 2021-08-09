import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/components/notification_dot.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/notification/notification_cubit.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/pages/profile_page.dart';
import 'package:spot/pages/view_video_page.dart';

class NotificationsTab extends StatelessWidget {
  static Widget create() {
    return Material(
      color: Colors.transparent,
      child: NotificationsTab(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaPadding = MediaQuery.of(context).padding;
    return BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
      if (state is NotificationInitial) {
        return preloader;
      } else if (state is NotificationEmpty) {
        return const Center(
            child: Text('You don\'t have any notifications yet'));
      } else if (state is NotificationLoaded) {
        final notifications = state.notifications;
        return RefreshIndicator(
          onRefresh: () {
            return BlocProvider.of<NotificationCubit>(context)
                .loadNotifications();
          },
          child: ListView.builder(
            padding: EdgeInsets.only(
              top: 16 + safeAreaPadding.top,
              bottom: 16 + safeAreaPadding.bottom,
            ),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _NotificationCell(
                notification: notifications[index],
              );
            },
          ),
        );
      }
      throw UnimplementedError();
    });
  }
}

class _NotificationCell extends StatelessWidget {
  const _NotificationCell({
    Key? key,
    required AppNotification notification,
  })  : _notification = notification,
        super(key: key);

  final AppNotification _notification;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        switch (_notification.type) {
          case NotificationType.like:
            Navigator.of(context)
                .push(ViewVideoPage.route(_notification.targetVideoId!));
            break;
          case NotificationType.comment:
            Navigator.of(context)
                .push(ViewVideoPage.route(_notification.targetVideoId!));
            break;
          case NotificationType.mentioned:
            Navigator.of(context)
                .push(ViewVideoPage.route(_notification.targetVideoId!));
            break;
          case NotificationType.follow:
            Navigator.of(context)
                .push(ProfilePage.route(_notification.actionUid!));
            break;
          case NotificationType.other:
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
        child: Row(
          children: [
            ProfileImage(
              imageUrl: _notification.actionUserImageUrl,
              onPressed: () {
                Navigator.of(context)
                    .push(ProfilePage.route(_notification.actionUid!));
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(text: _notificationText),
                        TextSpan(
                          text: ' ${howLongAgo(_notification.createdAt)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_notification.isNew)
                    const Positioned(
                      top: -2,
                      right: -2,
                      child: NotificationDot(),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(_notificationIconPath),
            ),
          ],
        ),
      ),
    );
  }

  String get _notificationText {
    switch (_notification.type) {
      case NotificationType.like:
        return '${_notification.actionUserName} liked your video';
      case NotificationType.comment:
        return '${_notification.actionUserName} commented "${_notification.commentText}"';
      case NotificationType.mentioned:
        return '${_notification.actionUserName} mentioned you in a comment "${_notification.commentText}"';
      case NotificationType.follow:
        return '${_notification.actionUserName} started following you';
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
      case NotificationType.mentioned:
        return 'assets/images/mentioned.png';
      case NotificationType.follow:
        return 'assets/images/follower.png';
      case NotificationType.other:
        return 'assets/images/like.png';
    }
  }
}
