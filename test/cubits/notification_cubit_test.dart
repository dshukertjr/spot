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
        when(repository.getNotifications).thenAnswer((_) => Future.value());
        when(() => repository.notificationsStream).thenAnswer((_) => Stream.value([
              AppNotification(
                type: NotificationType.like,
                createdAt: DateTime.now(),
                isNew: true,
                targetVideoId: 'aaa',
                targetVideoThumbnail: '',
                actionUid: 'abc',
                actionUserName: '',
              ),
            ]));
        return NotificationCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadNotifications();
      },
      expect: () => [
        isA<NotificationLoaded>(),
      ],
    );
    blocTest<NotificationCubit, NotificationState>(
      'Empty notifications will emit NotificationEmpty state',
      build: () {
        final repository = MockRepository();
        when(repository.getNotifications).thenAnswer((_) => Future.value([]));
        when(() => repository.notificationsStream)
            .thenAnswer((invocation) => Stream.fromIterable([[]]));
        return NotificationCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadNotifications();
      },
      expect: () => [
        isA<NotificationEmpty>(),
      ],
    );
  });

  group('NotificationCubit', () {
    final repository = MockRepository();
    final commentCubit = NotificationCubit(repository: repository);
    test('Can load notifications', () {
      when(repository.getNotifications).thenAnswer((invocation) => Future.value());
      when(() => repository.notificationsStream).thenAnswer((invocation) => Stream.fromIterable([
            [],
            [
              AppNotification(
                type: NotificationType.like,
                createdAt: DateTime.now(),
                targetVideoId: '',
                targetVideoThumbnail: 'https://dshukertjr.dev/images/profile.jpg',
                actionUid: 'aaa',
                actionUserName: 'Tyler',
                isNew: true,
              ),
              AppNotification(
                type: NotificationType.follow,
                createdAt: DateTime.now(),
                actionUid: 'aaa',
                actionUserName: 'Tyler',
                isNew: false,
              ),
              AppNotification(
                type: NotificationType.comment,
                createdAt: DateTime.now(),
                targetVideoId: '',
                targetVideoThumbnail: 'https://dshukertjr.dev/images/profile.jpg',
                actionUid: 'aaa',
                actionUserName: 'Tyler',
                commentText: 'hey',
                isNew: false,
              ),
            ]
          ]));

      expectLater(
        commentCubit.stream,
        emitsInOrder(
          [
            isA<NotificationEmpty>(),
            isA<NotificationLoaded>(),
          ],
        ),
      );
      commentCubit.loadNotifications();
    });
  });
}
