// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/record/record_cubit.dart';
import 'package:spot/pages/record_page.dart';

import '../helpers/helpers.dart';

class MockRecordCubit extends MockCubit<RecordState> implements RecordCubit {}

void main() {
  group('RecordPage', () {
    testWidgets('renders RecordPage', (tester) async {
      await tester.pumpApp(
        BlocProvider<RecordCubit>(
          create: (_) => RecordCubit()..initialize(),
          child: RecordPage(),
        ),
      );
      expect(find.text('Record'), findsOneWidget);
    });
  });

//   group('RecordPage', () {
//     late final RecordCubit recordCubit;

//     setUp(() {
//       recordCubit = MockRecordCubit();
//     });

//     // tearDown(() {
//     //   verifyMocks(recordCubit);
//     // });

//     testWidgets('renders circular progress indicator at initial state',
//         (tester) async {
//       final state = RecordInitial();
//       when<RecordCubit>(() => recordCubit).calls(#state).thenReturn(state);
//       await tester.pumpApp(
//         BlocProvider.value(
//           value: recordCubit,
//           child: RecordPage(),
//         ),
//       );
//       expect(find.byType(CircularProgressIndicator), findsOneWidget);
//     });
//   });
}
