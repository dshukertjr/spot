import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/record/record_cubit.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/repositories/repository.dart';

import '../helpers/helpers.dart';

class MockRecordCubit extends MockCubit<RecordState> implements RecordCubit {}

void main() {
  group('LoginPage', () {
    testWidgets('renders LoginPage', (tester) async {
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
}
