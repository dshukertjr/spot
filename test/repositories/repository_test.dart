import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';
import 'package:supabase/supabase.dart';

import '../helpers/helpers.dart';

// ignore_for_file: unawaited_futures

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
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
      mockServer = await HttpServer.bind('localhost', 0);
      supabaseClient =
          SupabaseClient('http://${mockServer.address.host}:${mockServer.port}', 'supabaseKey');
      handleRequests(mockServer);
    });

    tearDown(() async {
      await mockServer.close();
    });

    test('signUp', () async {
      final repository = Repository(supabaseClient: supabaseClient);

      final sessionString = await repository.signUp(email: '', password: '');

      expect(sessionString is String, true);
    });

    test('signIn', () async {
      final repository = Repository(supabaseClient: supabaseClient);

      final sessionString = await repository.signIn(email: '', password: '');

      expect(sessionString is String, true);
    });

    test('getSelfProfile', () async {
      final repository = Repository(supabaseClient: supabaseClient);

      await repository.signIn(email: '', password: '');

      final profile = await repository.getSelfProfile();

      expect(profile!.id, 'aaa');
    });

    test('getVideosFromLocation', () async {
      final repository = Repository(supabaseClient: supabaseClient);

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
      final repository = Repository(supabaseClient: supabaseClient);

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
      final repository = Repository(supabaseClient: supabaseClient);

      await repository.signIn(email: '', password: '');

      final videos = await repository.getVideosFromUid('aaa');

      expect(videos.length, 2);
      expect(videos.first.userId, 'aaa');
      expect(videos.first.id, 'a');
    });

    test('getProfile', () async {
      final repository = Repository(supabaseClient: supabaseClient);

      await repository.signIn(email: '', password: '');

      final profile = await repository.getProfile('aaa');

      expect(profile!.id, 'aaa');
    });

    test('saveProfile', () async {
      final repository = Repository(supabaseClient: supabaseClient);

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

    group('Mentions', () {
      test('getMentionedProfiles on a comment with email address', () {
        final repository = Repository(supabaseClient: supabaseClient);
        final comment = 'Email me at sample@example.com';
        repository.profilesCache.addAll({
          'aaa': Profile(
            id: 'aaa',
            name: 'John',
          ),
          'bbb': Profile(
            id: 'bbb',
            name: 'Mary',
          ),
        });
        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 0);
      });
      test('getMentionedProfiles on a comment with no mentions', () {
        final repository = Repository(supabaseClient: supabaseClient);
        final comment = 'What do you think?';
        repository.profilesCache.addAll({
          'aaa': Profile(
            id: 'aaa',
            name: 'John',
          ),
          'bbb': Profile(
            id: 'bbb',
            name: 'Mary',
          ),
        });
        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 0);
      });
      test('getMentionedProfiles at the beginning of sentence', () {
        final repository = Repository(supabaseClient: supabaseClient);
        final comment = '@John What do you think?';
        repository.profilesCache.addAll({
          'aaa': Profile(
            id: 'aaa',
            name: 'John',
          ),
          'bbb': Profile(
            id: 'bbb',
            name: 'Mary',
          ),
        });
        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 1);
        expect(profiles.first.id, 'aaa');
      });
      test('getMentionedProfiles in a sentence', () {
        final repository = Repository(supabaseClient: supabaseClient);
        final comment = 'Hey @John ! How are you?';
        repository.profilesCache.addAll({
          'aaa': Profile(
            id: 'aaa',
            name: 'John',
          ),
          'bbb': Profile(
            id: 'bbb',
            name: 'Mary',
          ),
        });
        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 1);
        expect(profiles.first.id, 'aaa');
      });
      test('getMentionedProfiles with one matching username', () {
        final repository = Repository(supabaseClient: supabaseClient);
        final comment = 'What do you think @John?';
        repository.profilesCache.addAll({
          'aaa': Profile(
            id: 'aaa',
            name: 'John',
          ),
          'bbb': Profile(
            id: 'bbb',
            name: 'Mary',
          ),
        });

        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 1);
        expect(profiles.first.id, 'aaa');
      });
      test('getMentionedProfiles with two matching username', () {
        final repository = Repository(supabaseClient: supabaseClient);
        final comment = 'What do you think @John, @Mary?';
        repository.profilesCache.addAll({
          'aaa': Profile(
            id: 'aaa',
            name: 'John',
          ),
          'bbb': Profile(
            id: 'bbb',
            name: 'Mary',
          ),
        });

        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 2);
        expect(profiles.first.id, 'aaa');
        expect(profiles[1].id, 'bbb');
      });
      test('getMentionedProfiles with space in the username would not work', () {
        final repository = Repository(supabaseClient: supabaseClient);
        final comment = 'What do you think @John Tyter?';
        repository.profilesCache.addAll({
          'aaa': Profile(
            id: 'aaa',
            name: 'John Tyter',
          ),
          'bbb': Profile(
            id: 'bbb',
            name: 'Mary',
          ),
        });

        final profiles = repository.getMentionedProfiles(comment);

        expect(profiles.length, 0);
      });
    });
  });

  group('replaceMentionsInAComment', () {
    final supabaseClient = SupabaseClient('', 'supabaseKey');
    final repository = Repository(supabaseClient: supabaseClient);
    test('without mention', () {
      final comment = '@test';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [],
      );
      expect(replacedComment, '@test');
    });

    test('user mentioned at the beginning', () {
      final comment = '@test';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          Profile(id: 'aaa', name: 'test'),
        ],
      );
      expect(replacedComment, '@aaa');
    });
    test('user mentioned multiple times', () {
      final comment = '@test @test';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          Profile(id: 'aaa', name: 'test'),
        ],
      );
      expect(replacedComment, '@aaa @aaa');
    });
    test('multiple user mentions', () {
      final comment = '@test @some';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          Profile(id: 'aaa', name: 'test'),
          Profile(id: 'bbb', name: 'some'),
        ],
      );
      expect(replacedComment, '@aaa @bbb');
    });
    test('there can be multiple mentions', () {
      final comment = '@test @some';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          Profile(id: 'aaa', name: 'test'),
          Profile(id: 'bbb', name: 'some'),
        ],
      );
      expect(replacedComment, '@aaa @bbb');
    });

    test('mention can be in a sentence', () {
      final comment = 'some comment @test more words';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          Profile(id: 'aaa', name: 'test'),
        ],
      );
      expect(replacedComment, 'some comment @aaa more words');
    });

    test('multiple user mentions', () {
      final comment = 'some comment @test';
      final replacedComment = repository.replaceMentionsInAComment(
        comment: comment,
        mentions: [
          Profile(id: 'aaa', name: 'test'),
        ],
      );
      expect(replacedComment, 'some comment @aaa');
    });
  });

  group('getMentionedUserName', () {
    final supabaseClient = SupabaseClient('', 'supabaseKey');
    final repository = Repository(supabaseClient: supabaseClient);
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
      final comment = 'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay';
      final userIds = repository.getUserIdsInComment(comment);
      expect(userIds, ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2']);
    });
    test('getUserIdsInComment with 2 user id', () {
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2';
      final userIds = repository.getUserIdsInComment(comment);
      expect(userIds,
          ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2', 'aaabac1a-8d4b-4361-99cc-a1d274d1c4d2']);
    });
    test('getUserIdsInComment with 2 user id with the same id', () {
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2';
      final userIds = repository.getUserIdsInComment(comment);
      expect(userIds,
          ['b35bac1a-8d4b-4361-99cc-a1d274d1c4d2', 'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2']);
    });
    test('replaceMentionsWithUserNames with two profiles', () {
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @aaabac1a-8d4b-4361-99cc-a1d274d1c4d2';
      final profiles = <String, Profile>{
        'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2': Profile(
          id: 'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2',
          name: 'Tyler',
        ),
        'aaabac1a-8d4b-4361-99cc-a1d274d1c4d2': Profile(
          id: 'aaabac1a-8d4b-4361-99cc-a1d274d1c4d2',
          name: 'Sam',
        ),
      };
      final updatedComment =
          repository.replaceMentionsWithUserNames(comment: comment, profiles: profiles);
      expect(updatedComment, 'something random @Tyler yay @Sam');
    });
    test('replaceMentionsWithUserNames with two userIds of the same user', () {
      final comment =
          'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2';
      final profiles = <String, Profile>{
        'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2': Profile(
          id: 'b35bac1a-8d4b-4361-99cc-a1d274d1c4d2',
          name: 'Tyler',
        ),
      };
      final updatedComment =
          repository.replaceMentionsWithUserNames(comment: comment, profiles: profiles);
      expect(updatedComment, 'something random @Tyler yay @Tyler');
    });
    test(
        'replaceMentionsWithUserNames where the profile was not found should not change the comment',
        () {
      final comment = 'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay';
      final profiles = <String, Profile>{};
      final updatedComment =
          repository.replaceMentionsWithUserNames(comment: comment, profiles: profiles);
      expect(updatedComment, 'something random @b35bac1a-8d4b-4361-99cc-a1d274d1c4d2 yay');
    });
  });
}
