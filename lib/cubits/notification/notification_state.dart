part of 'notification_cubit.dart';

@immutable
abstract class NotificationState {
  NotificationState({this.errorMessage});

  final String? errorMessage;
}

class NotificationInitial extends NotificationState {
  NotificationInitial({String? errorMessage})
      : super(errorMessage: errorMessage);
}

class NotificationLoaded extends NotificationState {
  NotificationLoaded({required this.notifications, String? errorMessage})
      : super(errorMessage: errorMessage);

  final List<AppNotification> notifications;
}
