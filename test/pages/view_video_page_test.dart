import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:spot/cubits/record/record_cubit.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/repositories/repository.dart';

import '../helpers/helpers.dart';

class MockRecordCubit extends MockCubit<RecordState> implements RecordCubit {}

void main() {
  group('ViewVideoPage', () {
    testWidgets('renders ViewVideoPage', (tester) async {
      final repository = MockRepository();
      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (context) =>
              VideoCubit(repository: RepositoryProvider.of<Repository>(context))..initialize(''),
          child: ViewVideoPage(),
        ),
        repository: repository,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
