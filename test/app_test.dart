import 'package:flutter_test/flutter_test.dart';
import 'package:spot/app/app.dart';
import 'package:spot/pages/splash_page.dart';

void main() {
  group('App', () {
    testWidgets('Renders App()', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(SplashPage), findsOneWidget);
    });
  });
}
