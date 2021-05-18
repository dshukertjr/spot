import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/pages/tabs/notifications_tab.dart';

import '../../helpers/helpers.dart';

void main() {
  /// This will allow http request to be sent within test code
  setUpAll(() => HttpOverrides.global = null);

  group('NotificationsTab', () {
    testWidgets('Renders NotificationsTab correctly', (tester) async {
      final repository = MockRepository();

      when(repository.getNotifications).thenAnswer((invocation) => Future.value([
            AppNotification(
              type: NotificationType.like,
              createdAt: DateTime.now(),
              targetVideoId: '',
              targetVideoThumbnail: 'https://dshukertjr.dev/images/profile.jpg',
              actionUid: 'aaa',
              actionUserName: 'Tyler',
              isNew: false,
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
          ]));

      await tester.pumpApp(
        widget: AppScaffold(body: NotificationsTab.create()),
        repository: repository,
      );

      expect(find.byWidget(preloader), findsOneWidget);
      expect(find.byType(ListView), findsNothing);

      await tester.pump();

      expect(find.byWidget(preloader), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      find
        ..byWidgetPredicate((widget) =>
            widget is RichText && widget.text.toPlainText().contains('liked your video'))
        ..byWidgetPredicate(
            (widget) => widget is RichText && widget.text.toPlainText().contains('commented'))
        ..byWidgetPredicate((widget) =>
            widget is RichText && widget.text.toPlainText().contains('started following you'));
    });
  });
}
