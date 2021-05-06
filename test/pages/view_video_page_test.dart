import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';

import '../helpers/helpers.dart';

class MockProfileCubit extends MockCubit<VideoState> implements VideoCubit {}

void main() {
  group('ViewVideoPage', () {
    testWidgets('renders ViewVideoPage', (tester) async {
      final videoCubit = MockProfileCubit();

      whenListen<VideoState>(
        videoCubit,
        Stream.fromIterable([
          VideoLoading(
            VideoDetail(
              id: 'id',
              url: 'url',
              imageUrl: 'imageUrl',
              thumbnailUrl: 'thumbnailUrl',
              gifUrl: 'gifUrl',
              createdAt: DateTime.now(),
              description: 'description',
              location: const LatLng(0, 0),
              userId: 'userId',
              likeCount: 0,
              commentCount: 0,
              haveLiked: false,
              createdBy: Profile(id: 'id', name: 'name'),
            ),
          ),
        ]),
        initialState: VideoInitial(),
      );
      final repository = MockRepository();
      await tester.pumpApp(
        widget: BlocProvider<VideoCubit>(
          create: (context) => videoCubit,
          child: ViewVideoPage(),
        ),
        repository: repository,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // group('RecordPage', () {
  //   late final VideoCubit videoCubit;

  //   setUp(() {
  //     videoCubit = MockVideoCubit();
  //   });

  //   // tearDown(() {
  //   //   verifyMocks(recordCubit);
  //   // });

  //   testWidgets('renders circular progress indicator at initial state', (tester) async {
  //     final state = RecordInitial();
  //     when<VideoCubit>(() => videoCubit).calls(#state).thenReturn(state);
  //     await tester.pumpApp(
  //       BlocProvider.value(
  //         value: videoCubit,
  //         child: RecordPage(),
  //       ),
  //     );
  //     expect(find.byType(CircularProgressIndicator), findsOneWidget);
  //   });
  // });
}
