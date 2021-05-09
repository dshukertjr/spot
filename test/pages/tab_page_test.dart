import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/pages/tab_page.dart';
import 'package:spot/pages/tabs/map_tab.dart';
import 'package:spot/pages/tabs/notifications_tab.dart';
import 'package:spot/pages/tabs/profile_tab.dart';
import 'package:spot/pages/tabs/search_tab.dart';

import '../helpers/helpers.dart';

void main() {
  group('TabPage', () {
    final repository = MockRepository();

    testWidgets('Every tab gets rendered', (tester) async {
      await tester.pumpApp(
        widget: TabPage(),
        repository: repository,
      );
      expect(find.byType(MapTab), findsOneWidget);
      expect(find.byType(SearchTab), findsOneWidget);
      expect(find.byType(NotificationsTab), findsOneWidget);
      expect(find.byType(ProfileTab), findsOneWidget);
    });

    testWidgets('Initial index is 0', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: tabPage,
        repository: repository,
      );
      expect(tabPage.createState().currentIndex, 0);
    });

    testWidgets('Tapping Home goes to tab index 0', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: tabPage,
        repository: repository,
      );
      await tester.tap(find.ancestor(of: find.text('Home'), matching: find.byType(InkResponse)));
      expect(tabPage.createState().currentIndex, 0);
    });
    testWidgets('Tapping Search goes to tab index 1', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: tabPage,
        repository: repository,
      );
      await tester.tap(find.ancestor(of: find.text('Search'), matching: find.byType(InkResponse)));
      expect(tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 1);
    });
    testWidgets('Tapping Notifications goes to tab index 2', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: tabPage,
        repository: repository,
      );
      await tester
          .tap(find.ancestor(of: find.text('Notifications'), matching: find.byType(InkResponse)));
      expect(tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 2);
    });
    testWidgets('Tapping Profile goes to tab index 3', (tester) async {
      final tabPage = TabPage();
      await tester.pumpApp(
        widget: tabPage,
        repository: repository,
      );
      await tester.tap(find.ancestor(of: find.text('Profile'), matching: find.byType(InkResponse)));
      expect(tester.state<TabPageState>(find.byWidget(tabPage)).currentIndex, 3);
    });
  });
}
