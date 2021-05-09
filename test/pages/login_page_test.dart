import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/pages/login_page.dart';
import 'package:spot/pages/profile_page.dart';

import '../helpers/helpers.dart';

void main() {
  group('LoginPage', () {
    testWidgets('Initially shown dialog is loginOrSignup', (tester) async {
      final repository = MockRepository();
      final loginPage = LoginPage();

      await tester.pumpApp(
        widget: loginPage,
        repository: repository,
      );

      await tester.pumpAndSettle();

      expect(tester.state<LoginPageState>(find.byWidget(loginPage)).currentDialogPage,
          DialogPage.loginOrSignup);
    });
    testWidgets('Renders LoginPage correctly', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('aaa')).thenAnswer((_) => Future.value(null));

      final loginPage = LoginPage();

      await tester.pumpApp(
        widget: loginPage,
        repository: repository,
      );

      expect(find.byWidget(preloader), findsWidgets);

      await tester.pump();

      expect(find.text('Profile not found'), findsOneWidget);
    });
  });
}
