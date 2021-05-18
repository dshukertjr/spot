import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/repositories/repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required Repository repository})
      : _repository = repository,
        super(NotificationInitial());

  final Repository _repository;
  final _notifications = <AppNotification>[];

  Future<void> initialize() async {
    try {
      final notifications = await _repository.getNotifications();
      _notifications.addAll(notifications);

      final hasNewNotification =
          _notifications.where((notification) => notification.isNew).isNotEmpty;

      emit(NotificationLoaded(
          notifications: _notifications, hasNewNotification: hasNewNotification));
    } catch (err) {
      emit(NotificationInitial(errorMessage: 'Error loading notifications'));
    }
  }

  Future<void> updateTimestampOfLastSeenNotification() async {
    if (_notifications.isNotEmpty) {
      return _repository.updateTimestampOfLastSeenNotification(_notifications.first.createdAt);
    }
  }
}
