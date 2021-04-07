import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/notification.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  Future<void> initialize() async {}
}
