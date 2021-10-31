import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/repositories/repository.dart';

part 'notification_state.dart';

/// Cubit that takes care of in app notifications
class NotificationCubit extends Cubit<NotificationState> {
  /// Cubit that takes care of in app notifications
  NotificationCubit({required Repository repository})
      : _repository = repository,
        super(NotificationInitial());

  final Repository _repository;
  List<AppNotification> _notifications = <AppNotification>[];
  StreamSubscription<List<AppNotification>>? _notificationListener;

  /// Sets up listeners to listen to notifications emitted on repository
  Future<void> loadNotifications() async {
    try {
      await _repository.getNotifications();
      _notificationListener =
          _repository.notificationsStream.listen((notifications) async {
        _notifications = notifications;
        if (_notifications.isEmpty) {
          emit(NotificationEmpty());
        } else {
          final hasNewNotification = _notifications
              .where((notification) => notification.isNew)
              .isNotEmpty;

          emit(NotificationLoaded(
              notifications: _notifications,
              hasNewNotification: hasNewNotification));
        }
      });
    } catch (err) {
      emit(NotificationInitial(errorMessage: 'Error loading notifications'));
    }
  }

  /// Called when a user has viewed a notification
  /// and want to update the last seen timestamp.
  /// Last seem timestamp is used to determine which
  /// notificatons are unread yet.
  Future<void> updateTimestampOfLastSeenNotification() async {
    if (_notifications.isNotEmpty) {
      emit(NotificationLoaded(
          notifications: _notifications, hasNewNotification: false));
      return _repository.updateTimestampOfLastSeenNotification(
          _notifications.first.createdAt);
    }
  }

  @override
  Future<void> close() {
    _notificationListener?.cancel();
    return super.close();
  }
}
