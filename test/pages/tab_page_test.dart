import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/components/frosted_dialog.dart';
import 'package:spot/components/notification_dot.dart';
import 'package:spot/cubits/notification/notification_cubit.dart';
import 'package:spot/data_profiders/app_link_provider.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/pages/edit_profile_page.dart';
import 'package:spot/pages/login_page.dart';
import 'package:spot/pages/record_page.dart';
import 'package:spot/pages/tab_page.dart';
import 'package:spot/pages/tabs/map_tab.dart';
import 'package:spot/pages/tabs/notifications_tab.dart';
import 'package:spot/pages/tabs/profile_tab.dart';
import 'package:spot/pages/tabs/search_tab.dart';
import 'package:spot/repositories/repository.dart';

import '../helpers/helpers.dart';
import '../test_resources/constants.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockAppLinkProvider extends Mock implements AppLinkProvider {}

class BuildContextFake extends Fake implements BuildContext {}

void main() {
  late final AppLinkProvider _appLinkProvider;

  /// This will allow http request to be sent within test code
  setUpAll(() {
    HttpOverrides.global = null;
    _appLinkProvider = MockAppLinkProvider();
    registerFallbackValue<BuildContext>(BuildContextFake());
    when(() => _appLinkProvider.setupAppLinks(any<BuildContext>()))
        .thenAnswer((_) async => null);
  });
  group('TabPage', () {
    group('signed in', () {
      late final Repository repository;
      setUpAll(() {
        repository = MockRepository();
        when(() => repository.userId).thenReturn('aaa');
        when(() => repository.myProfile).thenReturn(sampleProfile);
        when(() => repository.statusKnown).thenReturn(Completer()..complete());
        when(() => repository.myProfileHasLoaded)
            .thenReturn(Completer()..complete());
      });
      testWidgets('Every tab gets rendered', (tester) async {
        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) =>
                      NotificationCubit(repository: repository)),
            ],
            child: tabPage,
          ),
          repository: repository,
        );
        expect(find.byType(MapTab), findsOneWidget);
        expect(find.byType(SearchTab), findsOneWidget);
        expect(find.byType(NotificationsTab), findsOneWidget);
        expect(find.byType(ProfileTab), findsOneWidget);
      });

      testWidgets('Initial index is 0', (tester) async {
        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) =>
                      NotificationCubit(repository: repository)),
            ],
            child: tabPage,
          ),
          repository: repository,
        );
        expect(tabPage.createState().currentIndex, 0);
      });

      testWidgets('Tapping Home goes to tab index 0', (tester) async {
        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) =>
                      NotificationCubit(repository: repository)),
            ],
            child: tabPage,
          ),
          repository: repository,
        );
        await tester.tap(find.ancestor(
            of: find.text('Home'), matching: find.byType(InkResponse)));
        expect(tabPage.createState().currentIndex, 0);
      });
      testWidgets('Tapping Search goes to tab index 1', (tester) async {
        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) =>
                      NotificationCubit(repository: repository)),
            ],
            child: tabPage,
          ),
          repository: repository,
        );
        await tester.tap(find.ancestor(
            of: find.text('Search'), matching: find.byType(InkResponse)));
        expect(
            tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 1);
      });
      testWidgets('Tapping Notifications goes to tab index 2 when signed in',
          (tester) async {
        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) =>
                      NotificationCubit(repository: repository)),
            ],
            child: tabPage,
          ),
          repository: repository,
        );

        await tester.runAsync(() => tester.tap(find.ancestor(
            of: find.text('Notifications'),
            matching: find.byType(InkResponse))));
        expect(
            tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 2);
      });
      testWidgets('Tapping Profile goes to tab index 3 when signed in',
          (tester) async {
        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) =>
                      NotificationCubit(repository: repository)),
            ],
            child: tabPage,
          ),
          repository: repository,
        );
        await tester.runAsync(() async => await tester.tap(find.ancestor(
            of: find.text('Profile'), matching: find.byType(InkResponse))));
        expect(
            tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 3);
      });
    });

    group('not signed in', () {
      late final Repository repository;
      setUpAll(() {
        repository = MockRepository();
        when(() => repository.userId).thenReturn(null);
        when(() => repository.statusKnown).thenReturn(Completer()..complete());
        when(() => repository.hasAgreedToTermsOfService)
            .thenAnswer((invocation) async => true);
      });
      testWidgets('Tapping Notifications goes to LoginPage when not signed in',
          (tester) async {
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) => NotificationCubit(
                      repository: RepositoryProvider.of<Repository>(context))),
            ],
            child: TabPage(appLinkProvider: _appLinkProvider),
          ),
          repository: repository,
        );
        await tester.runAsync(() async => await tester.tap(
              find.ancestor(
                of: find.text('Notifications'),
                matching: find.byType(InkResponse),
              ),
            ));
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      });
      testWidgets('Tapping Profile goes to LoginPage when not signed in',
          (tester) async {
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) => NotificationCubit(
                      repository: RepositoryProvider.of<Repository>(context))),
            ],
            child: TabPage(appLinkProvider: _appLinkProvider),
          ),
          repository: repository,
        );
        await tester.runAsync(() async => await tester.tap(
              find.ancestor(
                of: find.text('Profile'),
                matching: find.byType(InkResponse),
              ),
            ));
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      });
      testWidgets(
          'Tapping record button when not signed in will open LoginPage',
          (tester) async {
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) => NotificationCubit(
                      repository: RepositoryProvider.of<Repository>(context))),
            ],
            child: TabPage(appLinkProvider: _appLinkProvider),
          ),
          repository: repository,
        );
        await tester
            .runAsync(() async => await tester.tap(find.byType(RecordButton)));
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      });
    });

    group('signed in, but no profile', () {
      late final Repository repository;
      setUpAll(() {
        repository = MockRepository();
        when(() => repository.userId).thenReturn('aaa');
        when(() => repository.statusKnown).thenReturn(Completer()..complete());
        when(() => repository.myProfileHasLoaded)
            .thenReturn(Completer()..complete());
        when(() => repository.myProfile).thenReturn(null);
        when(() => repository.profileStream)
            .thenAnswer((invocation) => Stream.value({}));
        when(() => repository.getProfileDetail('aaa'))
            .thenAnswer((invocation) async => null);
        when(() => repository.hasAgreedToTermsOfService)
            .thenAnswer((invocation) async => true);
      });
      testWidgets('Tapping Notifications goes to LoginPage', (tester) async {
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                  create: (context) => NotificationCubit(
                      repository: RepositoryProvider.of<Repository>(context))),
            ],
            child: TabPage(appLinkProvider: _appLinkProvider),
          ),
          repository: repository,
        );

        await tester.runAsync(() async => await tester.tap(find.ancestor(
            of: find.text('Notifications'),
            matching: find.byType(InkResponse))));
        await tester.pumpAndSettle();
        expect(find.byType(EditProfilePage), findsOneWidget);
      });
    });
  });

  group('NotificationDot', () {
    setUpAll(() {
      registerFallbackValue<DateTime>(DateTime.parse('2021-05-20T00:00:00.00'));
    });
    group('has notifications', () {
      late final Repository repository;
      setUpAll(() {
        repository = MockRepository();
        when(() => repository.statusKnown)
            .thenReturn(Completer<void>()..complete());
        when(() => repository.myProfileHasLoaded)
            .thenReturn(Completer<void>()..complete());

        when(() => repository.myProfile).thenReturn(sampleProfile);
        when(repository.getNotifications).thenAnswer((_) => Future.value());
      });
      testWidgets('Notification dots are shown properly', (tester) async {
        when(() => repository.notificationsStream)
            .thenAnswer((invocation) => Stream.value([
                  AppNotification(
                    type: NotificationType.like,
                    createdAt: DateTime.now(),
                    targetVideoId: '',
                    targetVideoThumbnail:
                        'https://dshukertjr.dev/images/profile.jpg',
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
                    targetVideoThumbnail:
                        'https://dshukertjr.dev/images/profile.jpg',
                    actionUid: 'aaa',
                    actionUserName: 'Tyler',
                    commentText:
                        'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2'
                        ' yay @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2',
                    isNew: false,
                  ),
                ]));
        when(() => repository.updateTimestampOfLastSeenNotification(any()))
            .thenAnswer((_) => Future.value());
        when(repository.determinePosition)
            .thenAnswer((_) => Future.value(const LatLng(0, 0)));
        when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
            .thenAnswer((_) => Future.value([]));
        when(() => repository.getVideosInBoundingBox(LatLngBounds(
                southwest: const LatLng(0, 0),
                northeast: const LatLng(45, 45))))
            .thenAnswer((_) => Future.value([]));
        when(() => repository.mapVideosStream)
            .thenAnswer((_) => Stream.value([]));
        when(() => repository.userId).thenReturn('aaa');
        when(() => repository.getProfileDetail('aaa'))
            .thenAnswer((_) => Future.value(sampleProfile));
        when((() => repository.profileStream))
            .thenAnswer((_) => Stream.value({}));
        when(() => repository.getVideosFromUid('aaa'))
            .thenAnswer((_) => Future.value([]));
        when(() => repository.replaceMentionsWithUserNames(
                'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay'
                ' @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2'))
            .thenAnswer(
                (invocation) async => 'something random @Tyler yay @Sam');

        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)
                  ..loadNotifications(),
              ),
            ],
            child: tabPage,
          ),
          repository: repository,
        );
        expect(find.byType(NotificationDot), findsNothing);
        await tester.pump();

        // Finds the one dot in notification tab and bottom tab bar
        expect(find.byType(NotificationDot), findsNWidgets(2));

        await tester.runAsync(() async => await tester.tap(find.ancestor(
            of: find.text('Notifications'),
            matching: find.byType(InkResponse))));
        await tester.pump();
        expect(find.byType(NotificationDot), findsNWidgets(1));
      });

      testWidgets(
          'Users who don\'t have timestampOfLastSeenNotification and have '
          'notifications will see a dot', (tester) async {
        when(() => repository.notificationsStream)
            .thenAnswer((invocation) => Stream.value([
                  AppNotification(
                    type: NotificationType.like,
                    createdAt: DateTime.now(),
                    targetVideoId: '',
                    targetVideoThumbnail:
                        'https://dshukertjr.dev/images/profile.jpg',
                    actionUid: 'aaa',
                    actionUserName: 'Tyler',
                    isNew: true,
                  ),
                ]));
        when(() => repository.updateTimestampOfLastSeenNotification(any()))
            .thenAnswer((_) => Future.value());
        when(repository.determinePosition)
            .thenAnswer((_) => Future.value(const LatLng(0, 0)));
        when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
            .thenAnswer((_) => Future.value([]));
        when(() => repository.getVideosInBoundingBox(LatLngBounds(
                southwest: const LatLng(0, 0),
                northeast: const LatLng(45, 45))))
            .thenAnswer((_) => Future.value([]));
        when(() => repository.mapVideosStream)
            .thenAnswer((_) => Stream.value([]));
        when(() => repository.userId).thenReturn('aaa');
        when(() => repository.getProfileDetail('aaa'))
            .thenAnswer((_) => Future.value(sampleProfile));
        when((() => repository.profileStream))
            .thenAnswer((_) => Stream.value({}));
        when(() => repository.getVideosFromUid('aaa'))
            .thenAnswer((_) => Future.value([]));

        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)
                  ..loadNotifications(),
              ),
            ],
            child: tabPage,
          ),
          repository: repository,
        );
        expect(find.byType(NotificationDot), findsNothing);
        await tester.pump();

        // Finds the one dot in notification tab and bottom tab bar
        expect(find.byType(NotificationDot), findsNWidgets(2));
        await tester.runAsync(() async => await tester.tap(find.ancestor(
            of: find.text('Notifications'),
            matching: find.byType(InkResponse))));
        await tester.pump();
        expect(find.byType(NotificationDot), findsOneWidget);
      });
    });

    group('does not have notifications', () {
      testWidgets(
          'Users without notifications should not see any Notification Dot',
          (tester) async {
        final repository = MockRepository();
        when(() => repository.statusKnown)
            .thenReturn(Completer<void>()..complete());
        when(() => repository.myProfileHasLoaded)
            .thenReturn(Completer<void>()..complete());

        when(() => repository.myProfile).thenReturn(sampleProfile);
        when(repository.getNotifications).thenAnswer(
          (_) => Future.value([]),
        );
        when(() => repository.updateTimestampOfLastSeenNotification(any()))
            .thenAnswer((_) => Future.value());
        when(repository.determinePosition)
            .thenAnswer((_) => Future.value(const LatLng(0, 0)));
        when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
            .thenAnswer((_) => Future.value([]));
        when(() => repository.getVideosInBoundingBox(LatLngBounds(
                southwest: const LatLng(0, 0),
                northeast: const LatLng(45, 45))))
            .thenAnswer((_) => Future.value([]));
        when(() => repository.mapVideosStream)
            .thenAnswer((_) => Stream.value([]));
        when(() => repository.userId).thenReturn('aaa');
        when(() => repository.getProfileDetail('aaa'))
            .thenAnswer((_) => Future.value(sampleProfile));
        when((() => repository.profileStream))
            .thenAnswer((_) => Stream.value({}));
        when(() => repository.getVideosFromUid('aaa'))
            .thenAnswer((_) => Future.value([]));

        final tabPage = TabPage(appLinkProvider: _appLinkProvider);
        await tester.pumpApp(
          widget: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(repository: repository)
                  ..loadNotifications(),
              ),
            ],
            child: tabPage,
          ),
          repository: repository,
        );
        expect(find.byType(NotificationDot), findsNothing);
        await tester.pump();

        // Finds the one dot in notification tab and bottom tab bar
        expect(find.byType(NotificationDot), findsNothing);
        await tester.runAsync(() async => await tester.tap(find.ancestor(
            of: find.text('Notifications'),
            matching: find.byType(InkResponse))));
        await tester.pump();
        expect(find.byType(NotificationDot), findsNothing);
      });
    });
  });

  group('Opening record page', () {
    setUpAll(() {
      registerFallbackValue<DateTime>(DateTime.parse('2021-05-20T00:00:00.00'));
    });
    testWidgets(
        'Users with location permission will be able to go to record page',
        (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('aaa');
      when(() => repository.myProfile).thenReturn(sampleProfile);
      when(() => repository.statusKnown)
          .thenReturn(Completer<void>()..complete());
      when(() => repository.myProfileHasLoaded)
          .thenReturn(Completer<void>()..complete());
      when(repository.getNotifications).thenAnswer(
        (_) => Future.value([]),
      );
      when(() => repository.updateTimestampOfLastSeenNotification(any()))
          .thenAnswer((_) => Future.value());
      when(repository.determinePosition)
          .thenAnswer((_) async => const LatLng(0, 0));
      when(repository.hasLocationPermission).thenAnswer((_) async => true);
      when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
          .thenAnswer((_) => Future.value([]));
      when(() => repository.getVideosInBoundingBox(LatLngBounds(
              southwest: const LatLng(0, 0), northeast: const LatLng(45, 45))))
          .thenAnswer((_) => Future.value([]));
      when(() => repository.mapVideosStream)
          .thenAnswer((_) => Stream.value([]));
      when(() => repository.userId).thenReturn('aaa');
      when(() => repository.getProfileDetail('aaa'))
          .thenAnswer((_) => Future.value(sampleProfile));
      when((() => repository.profileStream))
          .thenAnswer((_) => Stream.value({}));
      when(() => repository.getVideosFromUid('aaa'))
          .thenAnswer((_) => Future.value([]));

      final tabPage = TabPage(appLinkProvider: _appLinkProvider);
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
              create: (context) => NotificationCubit(repository: repository)
                ..loadNotifications(),
            ),
          ],
          child: tabPage,
        ),
        repository: repository,
      );

      await tester.pump();

      await tester.tap(find.descendant(
          of: find.byType(RecordButton), matching: find.byType(InkWell)));

      await tester.pump();

      expect(find.byType(RecordPage, skipOffstage: false), findsOneWidget);
      expect(find.byType(FrostedDialog), findsNothing);
    });

    testWidgets('Users without location permission will see a dialog',
        (tester) async {
      final repository = MockRepository();
      when(() => repository.userId).thenReturn('aaa');
      when(() => repository.myProfile).thenReturn(sampleProfile);
      when(() => repository.statusKnown)
          .thenReturn(Completer<void>()..complete());
      when(() => repository.myProfileHasLoaded)
          .thenReturn(Completer<void>()..complete());
      when(repository.getNotifications).thenAnswer(
        (_) => Future.value([]),
      );
      when(() => repository.updateTimestampOfLastSeenNotification(any()))
          .thenAnswer((_) => Future.value());
      when(repository.determinePosition)
          .thenAnswer((_) async => const LatLng(0, 0));
      when(repository.hasLocationPermission).thenAnswer((_) async => false);
      when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
          .thenAnswer((_) => Future.value([]));
      when(() => repository.getVideosInBoundingBox(LatLngBounds(
              southwest: const LatLng(0, 0), northeast: const LatLng(45, 45))))
          .thenAnswer((_) => Future.value([]));
      when(() => repository.mapVideosStream)
          .thenAnswer((_) => Stream.value([]));
      when(() => repository.userId).thenReturn('aaa');
      when(() => repository.getProfileDetail('aaa'))
          .thenAnswer((_) => Future.value(sampleProfile));
      when((() => repository.profileStream))
          .thenAnswer((_) => Stream.value({}));
      when(() => repository.getVideosFromUid('aaa'))
          .thenAnswer((_) => Future.value([]));

      final tabPage = TabPage(appLinkProvider: _appLinkProvider);
      await tester.pumpApp(
        widget: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationCubit>(
              create: (context) => NotificationCubit(repository: repository)
                ..loadNotifications(),
            ),
          ],
          child: tabPage,
        ),
        repository: repository,
      );

      await tester.pump();

      await tester.tap(find.byType(RecordButton));

      await tester.pump();

      expect(find.byType(RecordPage, skipOffstage: false), findsNothing);
      expect(find.byType(FrostedDialog), findsOneWidget);
    });
  });
}
