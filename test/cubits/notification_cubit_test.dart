import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/notification/notification_cubit.dart';
import 'package:spot/models/notification.dart';
import '../helpers/helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  test('Initial State', () {
    final repository = MockRepository();
    expect(NotificationCubit(repository: repository).state is NotificationInitial, true);
  });

  group('NotificationCubit initialize()', () {
    blocTest<NotificationCubit, NotificationState>(
      'Can load notifications',
      build: () {
        final repository = MockRepository();
        when(repository.getNotifications).thenAnswer((_) => Future.value([
              AppNotification(
                type: NotificationType.comment,
                createdAt: DateTime.now(),
                commentText: '',
                targetVideoId: '',
                targetVideoThumbnail: '',
                actionUid: '',
                actionUserName: '',
                actionUserImageUrl: '',
              ),
            ]));
        return NotificationCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.initialize();
      },
      expect: () => [
        isA<NotificationLoaded>(),
      ],
    );
  });
}
