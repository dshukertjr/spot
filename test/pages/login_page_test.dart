import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/pages/edit_profile_page.dart';
import 'package:spot/pages/login_page.dart';

import '../helpers/helpers.dart';

void main() {
  group('LoginPage', () {
    testWidgets('Renders LoginPage correctly', (tester) async {
      final repository = MockRepository();
      final loginPage = LoginPage();

      when(() => repository.hasAgreedToTermsOfService).thenAnswer((_) => Future.value(true));

      await tester.pumpApp(
        widget: loginPage,
        repository: repository,
      );

      await tester.pumpAndSettle();

      // Initial dialogPage is loginOrSignup
      expect(tester.state<LoginPageState>(find.byWidget(loginPage)).currentDialogPage,
          DialogPage.loginOrSignup);

      expect(find.text('Would you like to...'), findsOneWidget);
    });

    testWidgets('Agreeing to terms of service takes to loginorsignup dialog', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('aaa')).thenAnswer((_) => Future.value(null));
      when(() => repository.hasAgreedToTermsOfService).thenAnswer((_) => Future.value(false));
      when(repository.agreedToTermsOfService).thenAnswer((_) => Future.value(null));

      final loginPage = LoginPage();

      await tester.pumpApp(
        widget: loginPage,
        repository: repository,
      );

      await tester.pumpAndSettle();

      // Displaying terms of service dialog
      expect(find.text('Would you like to...'), findsNothing);
      expect(find.text('Agree'), findsOneWidget);

      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();

      // Displaying loginOrSignup
      expect(find.text('Would you like to...'), findsOneWidget);
      expect(find.text('Agree'), findsNothing);
    });

    testWidgets('Can go back and forth the signIn login dialog', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('aaa')).thenAnswer((_) => Future.value(null));
      when(() => repository.hasAgreedToTermsOfService).thenAnswer((_) => Future.value(true));

      final loginPage = LoginPage();

      await tester.pumpApp(
        widget: loginPage,
        repository: repository,
      );

      await tester.pumpAndSettle();

      // loginOrSignup dialog
      expect(tester.state<LoginPageState>(find.byWidget(loginPage)).currentDialogPage,
          DialogPage.loginOrSignup);

      // Open login dialog
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // Login dialog
      expect(tester.state<LoginPageState>(find.byWidget(loginPage)).currentDialogPage,
          DialogPage.login);

      // press back button
      await tester.tap(find.byIcon(FeatherIcons.chevronLeft));
      await tester.pumpAndSettle();

      expect(tester.state<LoginPageState>(find.byWidget(loginPage)).currentDialogPage,
          DialogPage.loginOrSignup);

      // Open sign up dialog
      await tester.tap(find.text('Create an Account'));
      await tester.pumpAndSettle();

      // Login dialog
      expect(tester.state<LoginPageState>(find.byWidget(loginPage)).currentDialogPage,
          DialogPage.signUp);
    });

    testWidgets('Login success will navigate to splash screen and EditProfilePage', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('aaa')).thenAnswer((_) => Future.value(null));
      when(() => repository.hasAgreedToTermsOfService).thenAnswer((_) => Future.value(true));
      when(() => repository.signIn(email: 'sample@spotvideo.app', password: 'securepassword'))
          .thenAnswer((_) => Future.value(''));
      when(() => repository.setSessionString('')).thenAnswer((invocation) => Future.value());
      when(() => repository.userId).thenReturn('aaa');
      when(repository.getSelfProfile).thenAnswer((invocation) => Future.value(null));
      when(() => repository.profileStream).thenAnswer((invocation) => Stream.value({}));
      when(repository.hasSession).thenAnswer((invocation) => Future.value(false));

      final loginPage = LoginPage();

      await tester.pumpApp(
        widget: loginPage,
        repository: repository,
      );

      await tester.pumpAndSettle();

      // Displaying loginOrSignup
      expect(find.text('Would you like to...'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithIcon(TextFormField, FeatherIcons.mail), 'sample@spotvideo.app');
      await tester.enterText(
          find.widgetWithIcon(TextFormField, FeatherIcons.lock), 'securepassword');

      await tester.tap(find.widgetWithText(GradientButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('Register success will navigate to splash screen and EditProfilePage',
        (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('aaa')).thenAnswer((_) => Future.value(null));
      when(() => repository.hasAgreedToTermsOfService).thenAnswer((_) => Future.value(true));
      when(() => repository.signUp(email: 'sample@spotvideo.app', password: 'securepassword'))
          .thenAnswer((_) => Future.value(''));
      when(() => repository.setSessionString('')).thenAnswer((invocation) => Future.value());
      when(() => repository.userId).thenReturn('aaa');
      when(repository.getSelfProfile).thenAnswer((invocation) => Future.value(null));
      when(() => repository.profileStream).thenAnswer((invocation) => Stream.value({}));
      when(repository.hasSession).thenAnswer((invocation) => Future.value(false));

      final loginPage = LoginPage();

      await tester.pumpApp(
        widget: loginPage,
        repository: repository,
      );

      await tester.pumpAndSettle();

      // Displaying loginOrSignup
      expect(find.text('Would you like to...'), findsOneWidget);

      await tester.tap(find.text('Create an Account'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithIcon(TextFormField, FeatherIcons.mail), 'sample@spotvideo.app');
      await tester.enterText(
          find.widgetWithIcon(TextFormField, FeatherIcons.lock), 'securepassword');

      await tester.tap(find.widgetWithText(GradientButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('Login fail will show error message', (tester) async {
      final repository = MockRepository();
      when(() => repository.getProfile('aaa')).thenAnswer((_) => Future.value(null));
      when(() => repository.hasAgreedToTermsOfService).thenAnswer((_) => Future.value(true));
      when(() => repository.signIn(email: 'sample@spotvideo.app', password: 'securepassword'))
          .thenThrow(PlatformException(code: '', message: 'Login Error'));
      when(() => repository.setSessionString('')).thenAnswer((invocation) => Future.value());
      when(() => repository.userId).thenReturn('aaa');
      when(repository.getSelfProfile).thenAnswer((invocation) => Future.value(null));
      when(() => repository.profileStream).thenAnswer((invocation) => Stream.value({}));
      when(repository.hasSession).thenAnswer((invocation) => Future.value(false));

      final loginPage = LoginPage();

      await tester.pumpApp(
        widget: loginPage,
        repository: repository,
      );

      await tester.pumpAndSettle();

      // Displaying loginOrSignup
      expect(find.text('Would you like to...'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithIcon(TextFormField, FeatherIcons.mail), 'sample@spotvideo.app');
      await tester.enterText(
          find.widgetWithIcon(TextFormField, FeatherIcons.lock), 'securepassword');

      await tester.tap(find.widgetWithText(GradientButton, 'Sign in'));

      await tester.pump();

      expect(find.text('Login Error'), findsOneWidget);
    });
  });
}
