import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';
import 'package:supabase/supabase.dart';

import '../test_resources/constants.dart';

// ignore_for_file: unawaited_futures

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  final analytics = MockFirebaseAnalytics();
  final localStorage = MockFlutterSecureStorage();

  setUp(() {
    registerFallbackValue<String>('');
    when(() => analytics.logEvent(name: any<String>(named: 'name')))
        .thenAnswer((invocation) async => null);
    when(() => analytics.logSignUp(
            signUpMethod: any<String>(named: 'signUpMethod')))
        .thenAnswer((invocation) async => null);
    when(() =>
            analytics.logLogin(loginMethod: any<String>(named: 'loginMethod')))
        .thenAnswer((invocation) async => null);
    when(() =>
            analytics.logSearch(searchTerm: any<String>(named: 'searchTerm')))
        .thenAnswer((invocation) async => null);
    when(() => localStorage.read(key: any<String>(named: 'key')))
        .thenAnswer((invocation) async => null);
  });

  group('repository', () {
    late SupabaseClient supabaseClient;
    late HttpServer mockServer;

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
        } else if (url ==
            '/rest/v1/users?select=%2A%2Cfollow%3Afk_followed%28%2A%29&id=eq.aaa&follow.following_user_id=eq.aaa') {
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
        } else if (url.contains('notifications')) {
          final jsonString = jsonEncode([]);
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

    setUpAll(() async {
      registerFallbackValue<String>('');
      mockServer = await HttpServer.bind('localhost', 0);
      supabaseClient = SupabaseClient(
          'http://${mockServer.address.host}:${mockServer.port}',
          'supabaseKey');
      handleRequests(mockServer);
    });

    tearDownAll(() async {
      await mockServer.close();
    });

    test('signUp', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);

      final sessionString = await repository.signUp(email: '', password: '');

      expect(sessionString is String, true);
    });

    test('signIn', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);

      final sessionString = await repository.signIn(email: '', password: '');

      expect(sessionString is String, true);
    });

    test('getMyProfile', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);

      await repository.signIn(email: '', password: '');

      await repository.statusKnown.future;
      await Future.delayed(const Duration(seconds: 1));
      final profile = repository.myProfile;

      expect(profile!.id, 'aaa');
    });

    test('getVideosFromLocation', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);

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
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);

      await repository.signIn(email: '', password: '');

      await repository.getVideosInBoundingBox(LatLngBounds(
          southwest: const LatLng(0, 0), northeast: const LatLng(45, 45)));

      repository.mapVideosStream.listen(
        expectAsync1(
          (videos) {
            expect(videos.length, 2);
          },
        ),
      );
    });

    test('getVideosFromUid', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);

      await repository.signIn(email: '', password: '');

      final videos = await repository.getVideosFromUid('aaa');

      expect(videos.length, 2);
      expect(videos.first.userId, 'aaa');
      expect(videos.first.id, 'a');
    });

    test('getProfile', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);

      await repository.signIn(email: '', password: '');

      final profile = await repository.getProfileDetail('aaa');

      expect(profile!.id, 'aaa');
    });

    test('saveProfile', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);

      await repository.signIn(email: '', password: '');

      await repository.saveProfile(profile: sampleProfile);

      repository.profileStream.listen(
        expectAsync1(
          (profiles) {
            expect(profiles['aaa']!.name, 'new');
          },
        ),
      );
    });

    group('Mentions', () {
      test('getMentionedProfiles on a comment with email address', () {
        final repository = Repository(
            supabaseClient: supabaseClient,
            analytics: analytics,
            localStorage: localStorage);
        final comment = 'Email me at sample@example.com';
        repository.profileDetailsCache.addAll({
          sampleProfileDetail.id: sampleProfileDetail,
          otherProfileDetail.id: otherProfileDetail,
        });
        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 0);
      });
      test('getMentionedProfiles on a comment with no mentions', () {
        final repository = Repository(
            supabaseClient: supabaseClient,
            analytics: analytics,
            localStorage: localStorage);
        final comment = 'What do you think?';
        repository.profileDetailsCache.addAll({
          sampleProfileDetail.id: sampleProfileDetail,
          otherProfileDetail.id: otherProfileDetail,
        });
        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 0);
      });
      test('getMentionedProfiles at the beginning of sentence', () {
        final repository = Repository(
            supabaseClient: supabaseClient,
            analytics: analytics,
            localStorage: localStorage);
        final comment = '@${sampleProfile.name} What do you think?';
        repository.profileDetailsCache.addAll({
          sampleProfileDetail.id: sampleProfileDetail,
          otherProfileDetail.id: otherProfileDetail,
        });
        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 1);
        expect(profiles.first.id, 'aaa');
      });
      test('getMentionedProfiles in a sentence', () {
        final repository = Repository(
            supabaseClient: supabaseClient,
            analytics: analytics,
            localStorage: localStorage);
        final comment = 'Hey @${sampleProfile.name} ! How are you?';
        repository.profileDetailsCache.addAll({
          sampleProfileDetail.id: sampleProfileDetail,
          otherProfileDetail.id: otherProfileDetail,
        });
        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 1);
        expect(profiles.first.id, 'aaa');
      });
      test('getMentionedProfiles with one matching username', () {
        final repository = Repository(
            supabaseClient: supabaseClient,
            analytics: analytics,
            localStorage: localStorage);
        final comment = 'What do you think @${sampleProfile.name}?';
        repository.profileDetailsCache.addAll({
          sampleProfileDetail.id: sampleProfileDetail,
          otherProfileDetail.id: otherProfileDetail,
        });

        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 1);
        expect(profiles.first.id, 'aaa');
      });
      test('getMentionedProfiles with two matching username', () {
        final repository = Repository(
            supabaseClient: supabaseClient,
            analytics: analytics,
            localStorage: localStorage);
        final comment =
            'What do you think @${sampleProfile.name}, @${otherProfile.name}?';
        repository.profileDetailsCache.addAll({
          sampleProfileDetail.id: sampleProfileDetail,
          otherProfileDetail.id: otherProfileDetail,
        });

        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 2);
        expect(profiles.first.id, 'aaa');
        expect(profiles[1].id, 'bbb');
      });
      test('getMentionedProfiles with space in the username would not work',
          () {
        final repository = Repository(
            supabaseClient: supabaseClient,
            analytics: analytics,
            localStorage: localStorage);
        final comment = 'What do you think @John Tyter?';
        repository.profileDetailsCache.addAll({
          sampleProfileDetail.id: sampleProfileDetail,
          otherProfileDetail.id: otherProfileDetail,
        });

        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 0);
      });
    });
  });

  group('replaceMentionsInAComment', () {
    final supabaseClient = SupabaseClient('', 'supabaseKey');
    final repository = Repository(
        supabaseClient: supabaseClient,
        analytics: analytics,
        localStorage: localStorage);
    test('without mention', () {
      final comment = '@test';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [],
      );
      expect(replacedComment, '@test');
    });

    test('user mentioned at the beginning', () {
      final comment = '@${sampleProfile.name}';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          sampleProfile,
        ],
      );
      expect(replacedComment, '@${sampleProfile.id}');
    });
    test('user mentioned multiple times', () {
      final comment = '@${sampleProfile.name} @${sampleProfile.name}';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [sampleProfile],
      );
      expect(replacedComment, '@${sampleProfile.id} @${sampleProfile.id}');
    });
    test('multiple user mentions', () {
      final comment = '@${sampleProfile.name} @${otherProfile.name}';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          sampleProfile,
          otherProfile,
        ],
      );
      expect(replacedComment, '@${sampleProfile.id} @${otherProfile.id}');
    });
    test('there can be multiple mentions', () {
      final comment = '@${sampleProfile.name} @${otherProfile.name}';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          sampleProfile,
          otherProfile,
        ],
      );
      expect(replacedComment, '@${sampleProfile.id} @${otherProfile.id}');
    });

    test('mention can be in a sentence', () {
      final comment = 'some comment @${sampleProfile.name} more words';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          sampleProfile,
        ],
      );
      expect(replacedComment, 'some comment @${sampleProfile.id} more words');
    });

    test('multiple user mentions', () {
      final comment = 'some comment @${sampleProfile.name}';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          sampleProfile,
        ],
      );
      expect(replacedComment, 'some comment @${sampleProfile.id}');
    });
  });

  group('getMentionedUserName', () {
    final supabaseClient = SupabaseClient('', 'supabaseKey');
    final repository = Repository(
        supabaseClient: supabaseClient,
        analytics: analytics,
        localStorage: localStorage);
    test('username is the only thing within the comment', () {
      final comment = '@test';
      final mentionedUserName = repository.getMentionedUserName(comment);
      expect(mentionedUserName, 'test');
    });
    test('username is at the end of comment', () {
      final comment = 'something @test';
      final mentionedUserName = repository.getMentionedUserName(comment);
      expect(mentionedUserName, 'test');
    });
    test('There are no @ sign in the comment', () {
      final comment = 'something test';
      final mentionedUserName = repository.getMentionedUserName(comment);
      expect(mentionedUserName, isNull);
    });
    test('@mention is not the last word in the comment', () {
      final comment = 'something @test another';
      final mentionedUserName = repository.getMentionedUserName(comment);
      expect(mentionedUserName, isNull);
    });
    test('There are multiple @ sign in the comment', () {
      final comment = 'something @test @some';
      final mentionedUserName = repository.getMentionedUserName(comment);
      expect(mentionedUserName, 'some');
    });
    test('getUserIdsInComment with 0 user id', () {
      final comment = 'some random text';
      final userIds = repository.getUserIdsInComment(comment);
      expect(userIds, []);
    });
    test('getUserIdsInComment with 1 user id at the beginning', () {
      final comment = '@b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay';
      final userIds = repository.getUserIdsInComment(comment);
      expect(userIds, ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2']);
    });
    test('getUserIdsInComment with 1 user id', () {
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay';
      final userIds = repository.getUserIdsInComment(comment);
      expect(userIds, ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2']);
    });
    test('getUserIdsInComment with 2 user id', () {
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2';
      final userIds = repository.getUserIdsInComment(comment);
      expect(userIds, [
        'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2',
        'aaabac1a-8d4b-4361-99cc-a1d274d1c4d2'
      ]);
    });
    test('getUserIdsInComment with 2 user id with the same id', () {
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2';
      final userIds = repository.getUserIdsInComment(comment);
      expect(userIds, [
        'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2',
        'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2'
      ]);
    });
  });

  group('replaceMentionsWithUserNames', () {
    late SupabaseClient supabaseClient;
    late HttpServer mockServer;

    Future<void> handleRequests(HttpServer server) async {
      await for (final HttpRequest request in server) {
        final url = request.uri.toString();
        if (url ==
            '/rest/v1/users?select=%2A&id=eq.b35bac1a-8d4b-4361-99cc-a1d274d1c4d2') {
          final jsonString = jsonEncode([
            {
              'id': 'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2',
              'name': 'Tyler',
              'description': 'Hi',
            },
          ]);
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonString)
            ..close();
        } else if (url ==
            '/rest/v1/users?select=%2A&id=eq.aaabac1a-8d4b-4361-99cc-a1d274d1c4d2') {
          final jsonString = jsonEncode([
            {
              'id': 'aaabac1a-8d4b-4361-99cc-a1d274d1c4d2',
              'name': 'Sam',
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
      mockServer = await HttpServer.bind('localhost', 0);
      supabaseClient = SupabaseClient(
          'http://${mockServer.address.host}:${mockServer.port}',
          'supabaseKey');
      handleRequests(mockServer);
    });

    tearDown(() async {
      await mockServer.close();
    });

    test('replaceMentionsWithUserNames with two profiles', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2';

      final updatedComment =
          await repository.replaceMentionsWithUserNames(comment);
      expect(updatedComment, 'something random @Tyler yay @Sam');
    });
    test('replaceMentionsWithUserNames with two userIds of the same user',
        () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2';

      final updatedComment =
          await repository.replaceMentionsWithUserNames(comment);
      expect(updatedComment, 'something random @Tyler yay @Tyler');
    });
    test('getZIndex', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);
      final recentZIndex = repository.getZIndex(DateTime(2021, 4, 10));
      expect(recentZIndex.isNegative, false);
      expect(recentZIndex < 1000000, true);

      final futureZIndex = repository.getZIndex(DateTime(2030, 4, 10));
      expect(futureZIndex.isNegative, false);
      expect(futureZIndex < 1000000, true);
    });
    test('getZIndex close ', () async {
      final repository = Repository(
          supabaseClient: supabaseClient,
          analytics: analytics,
          localStorage: localStorage);
      final firstZIndex =
          repository.getZIndex(DateTime(2021, 4, 10, 10, 0, 0)).toInt();
      final laterZIndex =
          repository.getZIndex(DateTime(2021, 4, 10, 11, 0, 0)).toInt();
      expect(firstZIndex < laterZIndex, true);
    });
  });
}
