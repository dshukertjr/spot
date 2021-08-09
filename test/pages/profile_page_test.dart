import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/pages/profile_page.dart';

import '../helpers/helpers.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('Renders ProfileNotFound correctly', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('aaa'))
          .thenAnswer((_) => Future.value(null));

      when(() => repository.getVideosFromUid('aaa')).thenAnswer(
        (invocation) => Future.value([]),
      );

      when(() => repository.profileStream).thenAnswer((_) => Stream.value({}));

      await tester.pumpApp(
        widget: const ProfilePage('aaa'),
        repository: repository,
      );
      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.text('Profile not found'), findsOneWidget);
    });

    testWidgets('Renders your own profile correctly', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('aaa')).thenAnswer((_) => Future.value(
          Profile(id: 'aaa', name: 'name', description: 'description')));

      when(() => repository.getVideosFromUid('aaa')).thenAnswer(
        (invocation) => Future.value([]),
      );

      when(() => repository.profileStream).thenAnswer((_) => Stream.value({
            'aaa': Profile(id: 'aaa', name: 'name', description: 'description'),
          }));

      when(() => repository.userId).thenReturn('aaa');

      await tester.pumpApp(
        widget: const ProfilePage('aaa'),
        repository: repository,
      );
      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.byType(ProfileImage), findsOneWidget);
      expect(find.text('description'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('Renders someone else\'s profile correctly', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('bbb')).thenAnswer((_) => Future.value(
          Profile(id: 'bbb', name: 'name', description: 'description')));

      when(() => repository.getVideosFromUid('aaa')).thenAnswer(
        (invocation) => Future.value([]),
      );

      when(() => repository.profileStream).thenAnswer((_) => Stream.value({
            'bbb': Profile(id: 'bbb', name: 'name', description: 'description'),
          }));

      when(() => repository.userId).thenReturn('aaa');

      await tester.pumpApp(
        widget: const ProfilePage('bbb'),
        repository: repository,
      );
      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.byType(ProfileImage), findsOneWidget);
      expect(find.text('description'), findsOneWidget);
      expect(find.text('Edit Profile'), findsNothing);
    });
  });
}
