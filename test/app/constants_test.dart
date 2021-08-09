import 'package:flutter_test/flutter_test.dart';
import 'package:spot/utils/constants.dart';

void main() {
  group('howLongAgo', () {
    testWidgets('time is after seed', (tester) async {
      final time = DateTime.parse('2021-05-20T00:00:05.00');
      final seed = DateTime.parse('2021-05-20T00:00:00.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, 'now');
    });

    testWidgets('within a minute', (tester) async {
      final time = DateTime.parse('2021-05-20T00:00:00.00');
      final seed = DateTime.parse('2021-05-20T00:00:05.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, 'now');
    });

    testWidgets('within a hour', (tester) async {
      final time = DateTime.parse('2021-05-20T00:00:00.00');
      final seed = DateTime.parse('2021-05-20T00:05:00.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, '5m');
    });

    testWidgets('within a day', (tester) async {
      final time = DateTime.parse('2021-05-20T00:00:00.00');
      final seed = DateTime.parse('2021-05-20T06:00:00.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, '6h');
    });

    testWidgets('within 30 days', (tester) async {
      final time = DateTime.parse('2021-05-20T00:00:00.00');
      final seed = DateTime.parse('2021-06-01T00:00:00.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, '12d');
    });

    testWidgets('same year', (tester) async {
      final time = DateTime.parse('2021-05-03T00:00:00.00');
      final seed = DateTime.parse('2021-09-01T00:00:00.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, '05-03');
    });

    testWidgets('same year in October', (tester) async {
      final time = DateTime.parse('2021-10-13T00:00:00.00');
      final seed = DateTime.parse('2021-12-26T00:00:00.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, '10-13');
    });

    testWidgets('diffferent year', (tester) async {
      final time = DateTime.parse('2020-05-03T00:00:00.00');
      final seed = DateTime.parse('2021-09-01T00:00:00.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, '2020-05-03');
    });

    testWidgets('diffferent year in October', (tester) async {
      final time = DateTime.parse('2020-10-13T00:00:00.00');
      final seed = DateTime.parse('2021-09-01T00:00:00.00');
      final howLongAgoString = howLongAgo(time, seed: seed);
      expect(howLongAgoString, '2020-10-13');
    });
  });
}
