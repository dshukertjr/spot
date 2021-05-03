import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/record/record_cubit.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/repositories/repository.dart';
import 'package:video_player/video_player.dart';

import '../helpers/helpers.dart';

class MockRecordCubit extends MockCubit<RecordState> implements RecordCubit {}

void main() {
  group('LoginPage', () {
    final repository = MockRepository();
    when<Stream<VideoDetail?>>(() => repository.videoDetailStream).thenAnswer(
      (_) => Stream.value(
        VideoDetail(
          id: '',
          url: '',
          imageUrl: '',
          thumbnailUrl: '',
          gifUrl: '',
          createdAt: DateTime.now(),
          description: '',
          location: const LatLng(0, 0),
          userId: '',
          likeCount: 0,
          commentCount: 0,
          haveLiked: false,
          createdBy: Profile(
            id: 'abc',
            name: 'test',
          ),
        ),
      ),
    );

    when<void>(() => repository.getVideoDetailStream('')).thenAnswer((_) => Future.value());
    testWidgets('renders LoginPage', (tester) async {
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

    testWidgets('starts playing the video', (tester) async {
      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (context) =>
              VideoCubit(repository: RepositoryProvider.of<Repository>(context))..initialize(''),
          child: ViewVideoPage(),
        ),
        repository: repository,
      );
      await tester.pump();
      expect(find.byType(VideoPlayer), findsOneWidget);
    });
  });
}
