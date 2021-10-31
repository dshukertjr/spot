import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/cubits/record/record_cubit.dart';

import '../helpers/helpers.dart';

void main() {
  group('RecordCubit', () {
    final repository = MockRepository();
    test('initial state is RecordInitial', () {
      expect(RecordCubit(repository: repository).state is RecordInitial, true);
    });

    blocTest<RecordCubit, RecordState>(
      'initialize will result in an error because '
      'emulators do not have cameras',
      build: () => RecordCubit(repository: repository),
      act: (cubit) async {
        await cubit.initialize();
      },
      expect: () => [isA<RecordError>()],
    );
  });
}
