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
    final notificationCubit = NotificationCubit(repository: repository);
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

      when(() => repository.replaceMentionsWithUserNames(any<String>()))
          .thenAnswer((invocation) async => '');

      expectLater(
        notificationCubit.stream,
        emitsInOrder(
          [
            isA<NotificationEmpty>(),
            isA<NotificationLoaded>(),
            isA<NotificationLoaded>(),
          ],
        ),
      );
      notificationCubit.loadNotifications();
    });
    test('Can load notifications with mentions', () {
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
                commentText:
                    'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2',
                isNew: false,
              ),
            ],
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
                commentText: 'something random @Tyler yay @Sam',
                isNew: false,
              ),
            ],
          ]));

      when(() => repository.replaceMentionsWithUserNames(any<String>()))
          .thenAnswer((invocation) async => 'something random @Tyler yay @Sam');

      expectLater(
        notificationCubit.stream,
        emitsInOrder(
          [
            isA<NotificationEmpty>(),
            isA<NotificationLoaded>(),
            isA<NotificationLoaded>(),
          ],
        ),
      );
      var count = 0;
      notificationCubit.stream.listen(
        (state) {
          if (count == 2 && state is NotificationLoaded) {
            expect(state.notifications.last.commentText, 'something random @Tyler yay @Sam');
          }
          count++;
        },
      );
      notificationCubit.loadNotifications();
    });
  });
}
