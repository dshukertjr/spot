import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/cubits/confirm_video/confirm_video_cubit.dart';
import '../helpers/helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  test('Initial State', () {
    final repository = MockRepository();
    expect(
        ConfirmVideoCubit(repository: repository).state is ConfirmVideoInitial,
        true);
  });

  // group('ConfirmVideoCubit initialize()', () {
  //   blocTest<ConfirmVideoCubit, ConfirmVideoState>(
  //     'Can load notifications',
  //     build: () {
  //       final repository = MockRepository();
  //       when(repository.getNotifications).thenAnswer((_) => Future.value([
  //             AppNotification(
  //               type: NotificationType.comment,
  //               createdAt: DateTime.now(),
  //               commentText: '',
  //               targetVideoId: '',
  //               targetVideoThumbnail: '',
  //               actionUid: '',
  //               actionUserName: '',
  //               actionUserImageUrl: '',
  //             ),
  //           ]));
  //       return ConfirmVideoCubit(repository: repository);
  //     },
  //     act: (cubit) async {
  //       await cubit.initialize(videoFile: File('test_resources/user.png'));
  //     },
  //     expect: () => [
  //       isA<NotificationLoaded>(),
  //     ],
  //   );
  // });
}
