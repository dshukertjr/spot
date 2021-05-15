import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/notification/notification_cubit.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/pages/profile_page.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/repositories/repository.dart';

class NotificationsTab extends StatelessWidget {
  static Widget create() {
    return BlocProvider<NotificationCubit>(
      create: (context) => NotificationCubit(
        repository: RepositoryProvider.of<Repository>(context),
      )..initialize(),
      child: Material(
        color: Colors.transparent,
        child: NotificationsTab(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaPadding = MediaQuery.of(context).padding;
    return BlocBuilder<NotificationCubit, NotificationState>(builder: (context, state) {
      if (state is NotificationInitial) {
        return preloader;
      } else if (state is NotificationLoaded) {
        final notifications = state.notifications;
        return ListView.builder(
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
  })   : _notification = notification,
        super(key: key);

  final AppNotification _notification;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        switch (_notification.type) {
          case NotificationType.like:
            Navigator.of(context).push(ViewVideoPage.route(_notification.targetVideoId!));
            break;
          case NotificationType.comment:
            Navigator.of(context).push(ViewVideoPage.route(_notification.targetVideoId!));
            break;
          case NotificationType.follow:
            Navigator.of(context).push(ProfilePage.route(_notification.actionUid!));
            break;
          default:
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
        child: Row(
          children: [
            ProfileImage(
              imageUrl: _notification.actionUserImageUrl,
              onPressed: () {
                Navigator.of(context).push(ProfilePage.route(_notification.actionUid!));
              },
            ),
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
        ),
      ),
    );
  }

  String get _notificationText {
    switch (_notification.type) {
      case NotificationType.like:
        return '${_notification.actionUserName} liked your video"';
      case NotificationType.comment:
        return '${_notification.actionUserName} commented "${_notification.commentText}"';
      case NotificationType.follow:
        return '${_notification.actionUserName} started following you"';
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
