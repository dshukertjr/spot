import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/subjects.dart';
import 'package:share/share.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:supabase/supabase.dart';
import 'package:video_player/video_player.dart';
import 'package:geocoding/geocoding.dart';

class Repository {
  Repository({
    required SupabaseClient supabaseClient,
    required FirebaseAnalytics analytics,
  })  : _supabaseClient = supabaseClient,
        _analytics = analytics;

  final SupabaseClient _supabaseClient;
  final FirebaseAnalytics _analytics;
  static const _localStorage = FlutterSecureStorage();
  static const _persistantSessionKey = 'supabase_session';
  static const _termsOfServiceAgreementKey = 'agreed';
  static const _timestampOfLastSeenNotification =
      'timestampOfLastSeenNotification';

  // Local Cache
  final List<Video> _mapVideos = [];
  final _mapVideosStreamConntroller = BehaviorSubject<List<Video>>();
  Stream<List<Video>> get mapVideosStream => _mapVideosStreamConntroller.stream;

  final Map<String, VideoDetail> _videoDetails = {};
  final _videoDetailStreamController = BehaviorSubject<VideoDetail?>();
  Stream<VideoDetail?> get videoDetailStream =>
      _videoDetailStreamController.stream;

  @visibleForTesting
  final Map<String, Profile> profilesCache = {};
  final _profileStreamController = BehaviorSubject<Map<String, Profile>>();
  Stream<Map<String, Profile>> get profileStream =>
      _profileStreamController.stream;

  @visibleForTesting
  List<Comment> comments = [];
  final _commentsStreamController = BehaviorSubject<List<Comment>>();
  Stream<List<Comment>> get commentsStream => _commentsStreamController.stream;

  List<AppNotification> _notifications = [];
  final _notificationsStreamController =
      BehaviorSubject<List<AppNotification>>();
  Stream<List<AppNotification>> get notificationsStream =>
      _notificationsStreamController.stream;

  final _mentionSuggestionCache = <String, List<Profile>>{};

  String? get userId => _supabaseClient.auth.currentUser?.id;

  Future<bool> get hasAgreedToTermsOfService =>
      _localStorage.containsKey(key: _termsOfServiceAgreementKey);

  Future<void> agreedToTermsOfService() =>
      _localStorage.write(key: _termsOfServiceAgreementKey, value: 'true');

  Future<bool> hasSession() =>
      _localStorage.containsKey(key: _persistantSessionKey);

  Future<String?> getSessionString() =>
      _localStorage.read(key: _persistantSessionKey);

  Future<void> deleteSession() =>
      _localStorage.delete(key: _persistantSessionKey);

  Future<void> setSessionString(String sessionString) =>
      _localStorage.write(key: _persistantSessionKey, value: sessionString);

  Future<Session?> recoverSession(String jsonString) async {
    final res = await _supabaseClient.auth.recoverSession(jsonString);
    final error = res.error;
    if (error != null) {
      throw PlatformException(code: 'login error', message: error.message);
    }
    return res.data;
  }

  /// Returns Persist Session String
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    final res = await _supabaseClient.auth.signUp(email, password);
    final error = res.error;
    if (error != null) {
      throw PlatformException(code: 'signup error', message: error.message);
    }
    await _analytics.logSignUp(signUpMethod: 'email');
    return res.data!.persistSessionString;
  }

  /// Returns Persist Session String
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    final res =
        await _supabaseClient.auth.signIn(email: email, password: password);
    final error = res.error;
    if (error != null) {
      throw PlatformException(code: 'login error', message: error.message);
    }
    await _analytics.logLogin(loginMethod: 'email');
    return res.data!.persistSessionString;
  }

  Future<Profile?> getSelfProfile() {
    final userId = this.userId;
    if (userId == null) {
      throw PlatformException(code: 'not signed in ', message: 'Not signed in');
    }
    return getProfile(userId);
  }

  Future<void> getVideosFromLocation(LatLng location) async {
    final res = await _supabaseClient
        .rpc('nearby_videos', params: {
          'location': 'POINT(${location.longitude} ${location.latitude})',
          'user_id': userId!,
        })
        .limit(5)
        .execute();
    final error = res.error;
    final data = res.data;
    if (error != null) {
      throw PlatformException(code: 'getVideosFromLocation error');
    } else if (data == null) {
      throw PlatformException(code: 'getVideosFromLocation error null data');
    }
    final videoIds = _mapVideos.map((video) => video.id);
    final newVideos = Video.videosFromData(data)
        .where((video) => !videoIds.contains(video.id));
    _mapVideos.addAll(newVideos);
    _mapVideosStreamConntroller.sink.add(_mapVideos);
  }

  Future<void> getVideosInBoundingBox(LatLngBounds bounds) async {
    final res = await _supabaseClient.rpc('videos_in_bouding_box', params: {
      'min_lng': '${bounds.southwest.longitude}',
      'min_lat': '${bounds.southwest.latitude}',
      'max_lng': '${bounds.northeast.longitude}',
      'max_lat': '${bounds.northeast.latitude}',
      'user_id': userId!,
    }).execute();
    final error = res.error;
    final data = res.data;
    if (error != null) {
      throw PlatformException(code: 'getVideosFromLocation error');
    } else if (data == null) {
      throw PlatformException(code: 'getVideosFromLocation error null data');
    }
    final videoIds = _mapVideos.map((video) => video.id);
    final newVideos = Video.videosFromData(data)
        .where((video) => !videoIds.contains(video.id));
    _mapVideos.addAll(newVideos);
    _mapVideosStreamConntroller.sink.add(_mapVideos);
  }

  Future<List<Video>> getVideosFromUid(String uid) async {
    final res = await _supabaseClient
        .from('videos')
        .select(
            'id, user_id, created_at, url, image_url, thumbnail_url, gif_url, description')
        .eq('user_id', uid)
        .order('created_at')
        .execute();
    final error = res.error;
    final data = res.data;
    if (error != null) {
      throw PlatformException(code: 'getVideosFromUid error');
    } else if (data == null) {
      throw PlatformException(code: 'getVideosFromUid error');
    }
    return Video.videosFromData(data);
  }

  Future<Profile?> getProfile(String uid) async {
    final targetProfile = profilesCache[uid];
    if (targetProfile != null) {
      return targetProfile;
    }
    final res =
        await _supabaseClient.from('users').select().eq('id', uid).execute();
    final data = res.data as List;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Database_Error',
        message: error.message,
      );
    }

    if (data.isEmpty) {
      _profileStreamController.sink.add(profilesCache);
      return null;
    }

    final profile = Profile.fromData(data[0]);
    profilesCache[uid] = profile;
    _profileStreamController.sink.add(profilesCache);
    return profile;
  }

  Future<void> saveProfile({required Profile profile}) async {
    final res = await _supabaseClient
        .from('users')
        .insert(profile.toMap(), upsert: true)
        .execute();
    final data = res.data;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Database_Error',
        message: error.message,
      );
    }
    if (data == null) {
      throw PlatformException(
        code: 'Database_Error',
        message: 'Error occured while saving profile',
      );
    }

    final newProfile = Profile.fromData(data[0]);
    profilesCache[profile.id] = newProfile;
    _profileStreamController.sink.add(profilesCache);
  }

  /// Uploads the video and returns the download URL
  Future<String> uploadFile({
    required String bucket,
    required File file,
    required String path,
  }) async {
    final res = await _supabaseClient.storage.from(bucket).upload(path, file);
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.error ?? 'uploadFile',
        message: error.message,
      );
    }
    final urlRes = await _supabaseClient.storage
        .from(bucket)
        .createSignedUrl(path, 60 * 60 * 24 * 365 * 50);
    final urlError = urlRes.error;
    if (urlError != null) {
      throw PlatformException(
        code: urlError.error ?? 'uploadFile',
        message: urlError.message,
      );
    }
    return urlRes.data!;
  }

  Future<void> saveVideo(Video creatingVideo) async {
    final res = await _supabaseClient
        .from('videos')
        .insert([creatingVideo.toMap()]).execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'saveVideo',
        message: error.message,
      );
    }
    final data = res.data;
    final createdVideo = creatingVideo.updateId(id: data[0]['id'] as String);
    _mapVideos.add(createdVideo);
    _mapVideosStreamConntroller.sink.add(_mapVideos);
    await _analytics.logEvent(name: 'post_video');
  }

  Future<void> getVideoDetailStream(String videoId) async {
    _videoDetailStreamController.sink.add(null);
    final userId = _supabaseClient.auth.currentUser!.id;
    final res = await _supabaseClient.rpc('get_video_detail',
        params: {'video_id': videoId, 'user_id': userId}).execute();
    final data = res.data;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Get Video Detail',
        message: error.message,
      );
    } else if (data == null) {
      throw PlatformException(
        code: 'Get Video Detail no data',
        message: 'No data found for this videoId',
      );
    }
    _videoDetails[videoId] =
        VideoDetail.fromData(Map.from(List.from(data).first));
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);
    await _analytics.logEvent(name: 'view_video', parameters: {
      'video_id': videoId,
    });
  }

  Future<void> like(String videoId) async {
    final currentVideoDetail = _videoDetails[videoId]!;
    _videoDetails[videoId] = currentVideoDetail.copyWith(
        likeCount: (currentVideoDetail.likeCount + 1), haveLiked: true);
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);

    final uid = _supabaseClient.auth.currentUser!.id;
    final res = await _supabaseClient.from('likes').insert([
      VideoDetail.like(videoId: videoId, uid: uid),
    ]).execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Like Video',
        message: error.message,
      );
    }
    await _analytics.logEvent(name: 'like_video', parameters: {
      'video_id': videoId,
    });
  }

  Future<void> unlike(String videoId) async {
    final currentVideoDetail = _videoDetails[videoId]!;
    _videoDetails[videoId] = currentVideoDetail.copyWith(
        likeCount: (currentVideoDetail.likeCount - 1), haveLiked: false);
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);

    final uid = _supabaseClient.auth.currentUser!.id;
    final res = await _supabaseClient
        .from('likes')
        .delete()
        .eq('video_id', videoId)
        .eq('user_id', uid)
        .execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Unlike Video',
        message: error.message,
      );
    }
    await _analytics.logEvent(name: 'unlike_video', parameters: {
      'video_id': videoId,
    });
  }

  Future<void> getComments(String videoId) async {
    final res = await _supabaseClient
        .from('video_comments')
        .select()
        .eq('video_id', videoId)
        .order('created_at')
        .execute();
    final data = res.data;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Unlike Video',
        message: error.message,
      );
    }
    comments = Comment.commentsFromData(List.from(data));
    _commentsStreamController.sink.add(comments);

    Future<Comment> replaceCommentText(Comment comment) async {
      final commentText = await replaceMentionsWithUserNames(comment.text);
      return comment.copyWith(text: commentText);
    }

    comments = await Future.wait(comments.map(replaceCommentText));
    _commentsStreamController.sink.add(comments);
    await _analytics.logEvent(name: 'view_comments', parameters: {
      'video_id': videoId,
    });
  }

  Future<void> comment({
    required String text,
    required String videoId,
    required List<Profile> mentions,
  }) async {
    final userId = _supabaseClient.auth.currentUser!.id;
    final res = await _supabaseClient
        .from('comments')
        .insert(Comment.create(text: text, userId: userId, videoId: videoId))
        .execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'commet Video',
        message: error.message,
      );
    }
    if (mentions.isEmpty) {
      return;
    }
    final commentId = res.data![0]['id'];
    final mentionRes = await _supabaseClient
        .from('mentions')
        .insert(mentions
            .where((mentionedProfile) =>
                mentionedProfile.id != _videoDetails[videoId]?.userId)
            .map((profile) => {
                  'comment_id': commentId,
                  'user_id': profile.id,
                })
            .toList())
        .execute();
    final mentionError = mentionRes.error;
    if (mentionError != null) {
      throw PlatformException(
        code: mentionError.code ?? 'commet Video',
        message: mentionError.message,
      );
    }
    await _analytics.logEvent(name: 'post_comment', parameters: {
      'video_id': videoId,
    });
  }

  Future<void> getNotifications() async {
    final uid = _supabaseClient.auth.currentUser!.id;
    final res = await _supabaseClient
        .from('notifications')
        .select()
        .eq('receiver_user_id', uid)
        .order('created_at')
        .limit(50)
        .execute();
    final data = res.data;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'getNotifications',
        message: error.message,
      );
    }
    final timestampOfLastSeenNotification =
        await _localStorage.read(key: _timestampOfLastSeenNotification);
    DateTime? createdAtOfLastSeenNotification;
    if (timestampOfLastSeenNotification != null) {
      createdAtOfLastSeenNotification =
          DateTime.parse(timestampOfLastSeenNotification);
    }
    _notifications = AppNotification.fromData(data,
        createdAtOfLastSeenNotification: createdAtOfLastSeenNotification);
    _notificationsStreamController.sink.add(_notifications);

    Future<AppNotification> replaceCommentTextWithMentionedUserName(
      AppNotification notification,
    ) async {
      if (notification.commentText == null) {
        return notification;
      }
      final commentText =
          await replaceMentionsWithUserNames(notification.commentText!);
      return notification.copyWith(commentText: commentText);
    }

    _notifications = await Future.wait(
        _notifications.map(replaceCommentTextWithMentionedUserName));
    _notificationsStreamController.sink.add(_notifications);
  }

  Future<void> block(String blockedUserId) async {
    final uid = _supabaseClient.auth.currentUser!.id;
    final res = await _supabaseClient.from('blocks').insert([
      {
        'user_id': uid,
        'blocked_user_id': blockedUserId,
      }
    ]).execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Unlike Video',
        message: error.message,
      );
    }
    _mapVideos.removeWhere((value) => value.userId == blockedUserId);
    _mapVideosStreamConntroller.sink.add(_mapVideos);
    await _analytics.logEvent(name: 'block_user', parameters: {
      'user_id': blockedUserId,
    });
  }

  Future<void> report({
    required String videoId,
    required String reason,
  }) async {
    final uid = _supabaseClient.auth.currentUser!.id;
    final res = await _supabaseClient.from('reports').insert({
      'user_id': uid,
      'video_id': videoId,
      'reason': reason,
    }).execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Report Video Error',
        message: error.message,
      );
    }
    await _analytics.logEvent(name: 'report_video', parameters: {
      'video_id': videoId,
    });
  }

  Future<void> delete({required String videoId}) async {
    final res = await _supabaseClient
        .from('videos')
        .delete()
        .eq('id', videoId)
        .execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Delete Video',
        message: error.message,
      );
    }
    _mapVideos.removeWhere((video) => video.id == videoId);
    _mapVideosStreamConntroller.sink.add(_mapVideos);
    await _analytics.logEvent(name: 'delete_video', parameters: {
      'video_id': videoId,
    });
  }

  Future<List<Video>> search(String queryString) async {
    final query = queryString.split(' ').map((word) => "'$word'").join(' & ');

    final res = await _supabaseClient
        .from('videos')
        .select(
            'id, url, image_url, thumbnail_url, gif_url, description, user_id, created_at')
        .textSearch('description', query, config: 'english')
        .order('created_at')
        .limit(50)
        .execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Unlike Video',
        message: error.message,
      );
    }
    final data = res.data as List;
    await _analytics.logSearch(searchTerm: queryString);
    return Video.videosFromData(data);
  }

  Future<VideoPlayerController> getVideoPlayerController(String url) async {
    return VideoPlayerController.network(url);
  }

  Future<bool> hasLocationPermission() async {
    final result = await Geolocator.requestPermission();
    return result != LocationPermission.denied &&
        result != LocationPermission.deniedForever;
  }

  Future<bool> openLocationSettingsPage() {
    return Geolocator.openLocationSettings();
  }

  Future<LatLng> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    final result = await Geolocator.requestPermission();
    if (result == LocationPermission.denied ||
        result == LocationPermission.deniedForever) {
      return const LatLng(37.43296265331129, -122.08832357078792);
    }

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LatLng(37.43296265331129, -122.08832357078792);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return const LatLng(37.43296265331129, -122.08832357078792);
      }

      if (permission == LocationPermission.denied) {
        return const LatLng(37.43296265331129, -122.08832357078792);
      }
    }
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> updateTimestampOfLastSeenNotification(DateTime time) async {
    await _localStorage.write(
        key: _timestampOfLastSeenNotification, value: time.toIso8601String());
  }

  Future<LatLng?> searchLocation(String searchQuery) async {
    try {
      final locations = await locationFromAddress(searchQuery);
      if (locations.isEmpty) {
        return null;
      }
      final location = locations.first;
      await _analytics.logEvent(
          name: 'search_location', parameters: {'search_term': searchQuery});
      return LatLng(location.latitude, location.longitude);
    } catch (e) {
      return null;
    }
  }

  Future<void> shareVideo(VideoDetail videoDetail) async {
    await Share.share(
        'Check out this video on Spot https://spotvideo.page.link/ias');
    await _analytics.logEvent(
        name: 'share_video', parameters: {'video_id': videoDetail.id});
  }

  Future<File> getCachedFile(String url) {
    return DefaultCacheManager().getSingleFile(url);
  }

  Future<List<Profile>> getMentions(String queryString) async {
    if (_mentionSuggestionCache[queryString] != null) {
      return _mentionSuggestionCache[queryString]!;
    }
    final res = await _supabaseClient
        .from('users')
        .select()
        .like('name', '%$queryString%')
        .limit(2)
        .execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
          code: 'Error finding mentionend users', message: error.message);
    }
    final data = List.from(res.data);
    final profiles = data
        .map<Profile>((row) => Profile.fromData(Map<String, dynamic>.from(row)))
        .toList();
    _mentionSuggestionCache[queryString] = profiles;
    profilesCache.addEntries(profiles.map<MapEntry<String, Profile>>(
        (profile) => MapEntry(profile.id, profile)));
    _profileStreamController.sink.add(profilesCache);
    return profiles;
  }

  List<Profile> getMentionedProfiles(String commentText) {
    final userNames = commentText
        .split(' ')
        .where((word) => word.isNotEmpty && word[0] == '@')
        .map((word) => RegExp(r'^\w*').firstMatch(word.substring(1))!.group(0)!)
        .toList();
    final userNameMap = <String, Profile>{}..addEntries(profilesCache.values
        .map<MapEntry<String, Profile>>(
            (profile) => MapEntry(profile.name, profile)));
    final mentionedProfiles = userNames
        .map<Profile?>((userName) => userNameMap[userName])
        .where((profile) => profile != null)
        .map<Profile>((profile) => profile!)
        .toList();
    return mentionedProfiles;
  }

  /// Replaces mentioned user names with users' id in comment text
  /// Called right before saving a new comment to the database
  String replaceMentionsInAComment(
      {required String comment, required List<Profile> mentions}) {
    var mentionReplacedText = comment;
    for (final mention in mentions) {
      mentionReplacedText =
          mentionReplacedText.replaceAll('@${mention.name}', '@${mention.id}');
    }
    return mentionReplacedText;
  }

  /// Extracts the username to be searched within the database
  /// Called when a user is typing up a comment
  String? getMentionedUserName(String comment) {
    final mention = comment.split(' ').last;
    if (mention.isEmpty || mention[0] != '@') {
      return null;
    }
    final mentionedUserName = mention.substring(1);
    if (mentionedUserName.isEmpty) {
      return null;
    }
    return mentionedUserName;
  }

  /// Returns list of userIds that are present in a comment
  List<String> getUserIdsInComment(String comment) {
    final regExp = RegExp(
        r'@[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b');
    final matches = regExp.allMatches(comment);
    return matches.map((match) => match.group(0)!.substring(1)).toList();
  }

  /// Replaces user ids found in comments with user names
  Future<String> replaceMentionsWithUserNames(
    String comment,
  ) async {
    await Future.wait(getUserIdsInComment(comment).map(getProfile).toList());
    final regExp = RegExp(
        r'@[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b');
    final replacedComment = comment.replaceAllMapped(regExp, (match) {
      final key = match.group(0)!.substring(1);
      final name = profilesCache[key]?.name;

      /// Return the original id if no profile was found with the id
      return '@${name ?? match.group(0)!.substring(1)}';
    });
    return replacedComment;
  }

  double getZIndex(DateTime createdAt) {
    return max((createdAt.millisecondsSinceEpoch ~/ 1000000 - 1600000), 0)
        .toDouble();
  }
}
