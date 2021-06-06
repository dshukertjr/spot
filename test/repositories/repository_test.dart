import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';
import 'package:supabase/supabase.dart';

// ignore_for_file: unawaited_futures

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('repository', () {
    late SupabaseClient supabaseClient;
    late HttpServer mockServer;
    late FirebaseAnalytics analytics;

    Future<void> handleRequests(HttpServer server) async {
      await for (final HttpRequest request in server) {
        final url = request.uri.toString();
        if (url == '/auth/v1/token?grant_type=password') {
          final jsonString = jsonEncode({
            'access_token': '',
            'expires_in': 3600,
            'refresh_token': '',
            'token_type': '',
            'provider_token': '',
            'user': {
              'id': 'aaa',
              'app_metadata': {},
              'user_metadata': {},
              'aud': '',
              'email': 'some@some.com',
              'created_at': '2021-04-17T00:00:30.75',
              'confirmed_at': '2021-04-17T00:00:30.75',
              'last_sign_in_at': '',
              'role': '',
              'updated_at': '2021-04-17T00:00:30.75',
            },
          });
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonString)
            ..close();
        } else if (url == '/auth/v1/signup') {
          final jsonString = jsonEncode({
            'access_token': '',
            'expires_in': 3600,
            'refresh_token': '',
            'token_type': '',
            'provider_token': '',
            'user': {
              'id': 'aaa',
              'app_metadata': {},
              'user_metadata': {},
              'aud': '',
              'email': 'some@some.com',
              'created_at': '2021-04-17T00:00:30.75',
              'confirmed_at': '2021-04-17T00:00:30.75',
              'last_sign_in_at': '',
              'role': '',
              'updated_at': '2021-04-17T00:00:30.75',
            },
          });
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonString)
            ..close();
        } else if (url == '/rest/v1/users?select=%2A&id=eq.aaa') {
          final jsonString = jsonEncode([
            {
              'id': 'aaa',
              'name': 'tyler',
              'description': 'Hi',
            },
          ]);
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonString)
            ..close();
        } else if (url == '/rest/v1/rpc/nearby_videos?limit=5') {
          final jsonString = jsonEncode([
            {
              'id': '',
              'url': '',
              'image_url': '',
              'thumbnail_url': '',
              'gif_url': '',
              'description': '',
              'user_id': '',
              'location': 'POINT(44.0 46.0)',
              'created_at': '2021-04-17T00:00:30.75',
            },
          ]);
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonString)
            ..close();
        } else if (url == '/rest/v1/rpc/videos_in_bouding_box') {
          final jsonString = jsonEncode([
            {
              'id': 'a',
              'url': '',
              'image_url': '',
              'thumbnail_url': '',
              'gif_url': '',
              'description': '',
              'user_id': '',
              'location': 'POINT(44.0 46.0)',
              'created_at': '2021-04-17T00:00:30.75',
            },
            {
              'id': 'b',
              'url': '',
              'image_url': '',
              'thumbnail_url': '',
              'gif_url': '',
              'description': '',
              'user_id': '',
              'location': 'POINT(44.0 46.0)',
              'created_at': '2021-04-17T00:00:30.75',
            },
          ]);
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonString)
            ..close();
        } else if (url ==
            '/rest/v1/videos?select=id%2Cuser_id%2Ccreated_at%2Curl%2Cimage_url%2Cthumbnail_url%2Cgif_url%2Cdescription&user_id=eq.aaa&order=%22created_at%22.desc.nullslast') {
          final jsonString = jsonEncode([
            {
              'id': 'a',
              'url': '',
              'image_url': '',
              'thumbnail_url': '',
              'gif_url': '',
              'description': '',
              'user_id': 'aaa',
              'created_at': '2021-04-17T00:00:30.75',
            },
            {
              'id': 'b',
              'url': '',
              'image_url': '',
              'thumbnail_url': '',
              'gif_url': '',
              'description': '',
              'user_id': 'aaa',
              'created_at': '2021-04-17T00:00:30.75',
            },
          ]);
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonString)
            ..close();
        } else if (url == '/rest/v1/users') {
          final jsonString = jsonEncode([
            {
              'id': 'aaa',
              'name': 'new',
              'description': 'Hi',
            },
          ]);
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonString)
            ..close();
        } else {
          request.response
            ..statusCode = HttpStatus.ok
            ..close();
        }
      }
    }

    setUp(() async {
      registerFallbackValue<String>('');
      mockServer = await HttpServer.bind('localhost', 0);
      supabaseClient =
          SupabaseClient('http://${mockServer.address.host}:${mockServer.port}', 'supabaseKey');
      handleRequests(mockServer);
      analytics = MockFirebaseAnalytics();
      when(() => analytics.logEvent(name: any<String>(named: 'name')))
          .thenAnswer((invocation) async => null);
      when(() => analytics.logSignUp(signUpMethod: any<String>(named: 'signUpMethod')))
          .thenAnswer((invocation) async => null);
      when(() => analytics.logLogin(loginMethod: any<String>(named: 'loginMethod')))
          .thenAnswer((invocation) async => null);
      when(() => analytics.logSearch(searchTerm: any<String>(named: 'searchTerm')))
          .thenAnswer((invocation) async => null);
    });

    tearDown(() async {
      await mockServer.close();
    });

    test('signUp', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);

      final sessionString = await repository.signUp(email: '', password: '');

      expect(sessionString is String, true);
    });

    test('signIn', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);

      final sessionString = await repository.signIn(email: '', password: '');

      expect(sessionString is String, true);
    });

    test('getSelfProfile', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);

      await repository.signIn(email: '', password: '');

      final profile = await repository.getSelfProfile();

      expect(profile!.id, 'aaa');
    });

    test('getVideosFromLocation', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);

      await repository.signIn(email: '', password: '');

      await repository.getVideosFromLocation(const LatLng(45.0, 45.0));

      repository.mapVideosStream.listen(
        expectAsync1(
          (videos) {
            expect(videos.length, 1);
          },
        ),
      );
    });

    test('getVideosInBoundingBox', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);

      await repository.signIn(email: '', password: '');

      await repository.getVideosInBoundingBox(
          LatLngBounds(southwest: const LatLng(0, 0), northeast: const LatLng(45, 45)));

      repository.mapVideosStream.listen(
        expectAsync1(
          (videos) {
            expect(videos.length, 2);
          },
        ),
      );
    });

    test('getVideosFromUid', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);

      await repository.signIn(email: '', password: '');

      final videos = await repository.getVideosFromUid('aaa');

      expect(videos.length, 2);
      expect(videos.first.userId, 'aaa');
      expect(videos.first.id, 'a');
    });

    test('getProfile', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);

      await repository.signIn(email: '', password: '');

      final profile = await repository.getProfile('aaa');

      expect(profile!.id, 'aaa');
    });

    test('saveProfile', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);

      await repository.signIn(email: '', password: '');

      await repository.saveProfile(profile: Profile(id: 'aaa', name: 'new'));

      repository.profileStream.listen(
        expectAsync1(
          (profiles) {
            expect(profiles['aaa']!.name, 'new');
          },
        ),
      );
    });

    test('getZIndex', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);
      final recentZIndex = repository.getZIndex(DateTime(2021, 4, 10));
      expect(recentZIndex.isNegative, false);
      expect(recentZIndex < 1000000, true);

      final futureZIndex = repository.getZIndex(DateTime(2030, 4, 10));
      expect(futureZIndex.isNegative, false);
      expect(futureZIndex < 1000000, true);
    });
    test('getZIndex close ', () async {
      final repository = Repository(supabaseClient: supabaseClient, analytics: analytics);
      final firstZIndex = repository.getZIndex(DateTime(2021, 4, 10, 10, 0, 0)).toInt();
      final laterZIndex = repository.getZIndex(DateTime(2021, 4, 10, 11, 0, 0)).toInt();
      expect(firstZIndex < laterZIndex, true);
    });
  });
}
