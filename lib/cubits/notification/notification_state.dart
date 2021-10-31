part of 'notification_cubit.dart';

@immutable

/// Base state for notifications
abstract class NotificationState {
  /// Base state for notifications
  NotificationState({this.errorMessage});

  /// Message to display to users if there were any errors
  final String? errorMessage;
}

/// Initial state
class NotificationInitial extends NotificationState {
  /// Initial state
  NotificationInitial({String? errorMessage})
      : super(errorMessage: errorMessage);
}

/// Done loading and none were found
class NotificationEmpty extends NotificationState {
  /// Done loading and none were found
  NotificationEmpty({String? errorMessage}) : super(errorMessage: errorMessage);
}

/// Done loading and notifications were found
class NotificationLoaded extends NotificationState {
  /// Done loading and notifications were found
  NotificationLoaded({
    required this.notifications,
    required this.hasNewNotification,
    String? errorMessage,
  }) : super(errorMessage: errorMessage);

  /// List of notifications
  final List<AppNotification> notifications;

  /// Whether there are unread notifications or not
  final bool hasNewNotification;
}
