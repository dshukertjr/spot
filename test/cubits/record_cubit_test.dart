import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:spot/cubits/record/record_cubit.dart';

void main() {
  group('RecordCubit', () {
    test('initial state is RecordInitial', () {
      expect(RecordCubit().state is RecordInitial, true);
    });

    blocTest<RecordCubit, RecordState>(
      'initialize will result in an error because emulators do not have cameras',
      build: () => RecordCubit(),
      act: (cubit) async {
        await cubit.initialize();
      },
      expect: () => [isA<RecordError>()],
    );
  });
}
