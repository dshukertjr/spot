import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/pages/profile_page.dart';
import 'package:spot/utils/constants.dart';

import '../helpers/helpers.dart';
import '../test_resources/constants.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('Renders ProfileNotFound correctly', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfileDetail('aaa'))
          .thenAnswer((_) => Future.value(null));

      when(() => repository.getVideosFromUid('aaa')).thenAnswer(
        (invocation) => Future.value([]),
      );

      when(() => repository.profileStream).thenAnswer((_) => Stream.value({}));

      await tester.pumpApp(
        widget: BlocProvider(
          create: (context) =>
              ProfileCubit(repository: repository)..loadProfile('aaa'),
          child: const ProfilePage('aaa'),
        ),
        repository: repository,
      );
      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.text('Profile not found'), findsOneWidget);
    });

    testWidgets('Renders your own profile correctly', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfileDetail('aaa'))
          .thenAnswer((_) => Future.value(sampleProfile));

      when(() => repository.getVideosFromUid('aaa')).thenAnswer(
        (invocation) => Future.value([]),
      );

      when(() => repository.profileStream).thenAnswer((_) => Stream.value({
            sampleProfileDetail.id: sampleProfileDetail,
          }));

      when(() => repository.userId).thenReturn('aaa');

      await tester.pumpApp(
        widget: BlocProvider(
          create: (context) =>
              ProfileCubit(repository: repository)..loadProfile('aaa'),
          child: const ProfilePage('aaa'),
        ),
        repository: repository,
      );
      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.byType(ProfileImage), findsOneWidget);
      expect(find.text(sampleProfile.description!), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Follow'), findsNothing);
    });

    testWidgets('Renders someone else\'s profile correctly', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfileDetail('bbb'))
          .thenAnswer((_) => Future.value(otherProfile));

      when(() => repository.getVideosFromUid('aaa')).thenAnswer(
        (invocation) => Future.value([]),
      );

      when(() => repository.profileStream).thenAnswer((_) => Stream.value({
            otherProfileDetail.id: otherProfileDetail,
          }));

      when(() => repository.userId).thenReturn('aaa');

      await tester.pumpApp(
        widget: BlocProvider(
          create: (context) =>
              ProfileCubit(repository: repository)..loadProfile('bbb'),
          child: const ProfilePage('bbb'),
        ),
        repository: repository,
      );
      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.byType(ProfileImage), findsOneWidget);
      expect(find.text(otherProfile.description!), findsOneWidget);
      expect(find.text('Edit Profile'), findsNothing);
      expect(find.text('Follow'), findsOneWidget);
    });
  });
}
