import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/cubits/confirm_video/confirm_video_cubit.dart';
import 'package:spot/pages/confirm_recording_page.dart';

import '../helpers/helpers.dart';

void main() {
  group('ConfirmRecordingPage', () {
    testWidgets('Renders ConfirmRecordingPage', (tester) async {
      final repository = MockRepository();

      when(() => repository.hasAgreedToTermsOfService)
          .thenAnswer((_) => Future.value(true));

      await tester.pumpApp(
        widget: BlocProvider<ConfirmVideoCubit>(
          create: (context) => ConfirmVideoCubit(repository: repository)
            ..initialize(videoFile: File('test_resources/video.mp4')),
          child: ConfirmRecordingPage(),
        ),
        repository: repository,
      );

      expect(find.byWidget(preloader), findsOneWidget);
    });
  });
}
