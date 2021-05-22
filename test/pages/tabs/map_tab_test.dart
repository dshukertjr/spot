import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/tabs/map_tab.dart';

import '../../helpers/helpers.dart';

void main() {
  /// This will allow http request to be sent within test code
  setUpAll(() {
    HttpOverrides.global = null;
  });

  group('MapTab', () {
    testWidgets('Renders MapTab correctly', (tester) async {
      final repository = MockRepository();

      when(repository.determinePosition)
          .thenAnswer((invocation) => Future.value(const LatLng(0, 0)));
      when(() => repository.mapVideosStream).thenAnswer((invocation) => Stream.value([
            Video(
              id: 'id',
              url: 'https://www.w3schools.com/html/mov_bbb.mp4',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now(),
              description: 'description',
              userId: 'userId',
              location: const LatLng(0, 0),
            )
          ]));

      when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
          .thenAnswer((invocation) => Future.value());

      await tester.pumpApp(
        widget: AppScaffold(body: MapTab.create()),
        repository: repository,
      );

      expect(find.byWidget(preloader), findsOneWidget);
      expect(find.byType(GoogleMap), findsNothing);

      await tester.pump();

      expect(find.byWidget(preloader), findsNothing);
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('Can search the map by city name', (tester) async {
      final repository = MockRepository();

      when(repository.determinePosition)
          .thenAnswer((invocation) => Future.value(const LatLng(0, 0)));
      when(() => repository.mapVideosStream).thenAnswer((invocation) => Stream.value([
            Video(
              id: 'id',
              url: 'https://www.w3schools.com/html/mov_bbb.mp4',
              imageUrl: 'https://dshukertjr.dev/images/profile.jpg',
              thumbnailUrl: 'https://dshukertjr.dev/images/profile.jpg',
              gifUrl: 'https://dshukertjr.dev/images/profile.jpg',
              createdAt: DateTime.now(),
              description: 'description',
              userId: 'userId',
              location: const LatLng(0, 0),
            )
          ]));

      when(() => repository.getVideosFromLocation(const LatLng(0, 0)))
          .thenAnswer((invocation) => Future.value());

      when(() => repository.searchLocation('Tokyo')).thenAnswer((_) async => const LatLng(45, 45));

      await tester.pumpApp(
        widget: AppScaffold(body: MapTab.create()),
        repository: repository,
      );

      expect(find.byWidget(preloader), findsOneWidget);
      expect(find.byType(GoogleMap), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byWidget(preloader), findsNothing);
      expect(find.byType(GoogleMap), findsOneWidget);

      await tester.showKeyboard(find.byType(TextFormField));

      await tester.enterText(find.byType(TextFormField), 'Tokyo');

      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pump();

      verify(() => repository.searchLocation('Tokyo')).called(1);
    });
  });
}
