import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/cubits/search/search_cubit.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/tabs/search_tab.dart';
import '../../helpers/helpers.dart';

void main() {
  /// This will allow http request to be sent within test code
  setUpAll(() => HttpOverrides.global = null);

  group('SearchTab', () {
    testWidgets('Renders initial videos properly', (tester) async {
      final repository = MockRepository();

      when(repository.getNewVideos).thenAnswer((invocation) async => [
            Video(
              id: 'id',
              url: 'url',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now(),
              description: 'description',
              userId: 'userId',
              position: const LatLng(45, 45),
              isFollowing: false,
            ),
          ]);

      await tester.pumpApp(
        widget: BlocProvider<SearchCubit>(
          create: (context) =>
              SearchCubit(repository: repository)..loadInitialVideos(),
          child: AppScaffold(body: SearchTab.create()),
        ),
        repository: repository,
      );

      expect(find.byWidget(preloader), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      await tester.pump();

      expect(find.byWidget(preloader), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Can search videos', (tester) async {
      final repository = MockRepository();

      when(repository.getNewVideos).thenAnswer((invocation) async => [
            Video(
              id: 'id',
              url: 'url',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now(),
              description: 'description',
              userId: 'userId',
              position: const LatLng(45, 45),
              isFollowing: false,
            ),
          ]);

      when(() => repository.search('aaa')).thenAnswer((invocation) async => [
            Video(
              id: 'id',
              url: 'url',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now(),
              description: 'description',
              userId: 'userId',
              position: const LatLng(45, 45),
              isFollowing: false,
            ),
            Video(
              id: 'id',
              url: 'url',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now(),
              description: 'description',
              userId: 'userId',
              position: const LatLng(45, 45),
              isFollowing: false,
            ),
          ]);

      await tester.pumpApp(
        widget: BlocProvider<SearchCubit>(
          create: (context) =>
              SearchCubit(repository: repository)..loadInitialVideos(),
          child: AppScaffold(body: SearchTab.create()),
        ),
        repository: repository,
      );

      await tester.pump();

      expect(find.byType(TextFormField), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'aaa');
      await tester.tap(find.byIcon(FeatherIcons.search));

      await tester.pump();

      expect(find.byWidget(preloader), findsNothing);
      expect(find.byType(Image), findsNWidgets(2));
    });
  });
}
