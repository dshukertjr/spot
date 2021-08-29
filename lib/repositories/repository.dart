import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
    required FlutterSecureStorage localStorage,
  })  : _supabaseClient = supabaseClient,
        _analytics = analytics,
        _localStorage = localStorage {
    setAuthListenner();
  }

  final SupabaseClient _supabaseClient;
  final FirebaseAnalytics _analytics;
  final FlutterSecureStorage _localStorage;
  // static const _localStorage = FlutterSecureStorage();
  static const _persistantSessionKey = 'supabase_session';
  static const _termsOfServiceAgreementKey = 'agreed';
  static const _timestampOfLastSeenNotification =
      'timestampOfLastSeenNotification';

  /// Used as a placeholder for myUserId when loading data that requires myUserID but not signed in
  static const _anonymousUUID = '00000000-0000-0000-0000-000000000000';

  // Local Cache
  final List<Video> _mapVideos = [];
  final _mapVideosStreamConntroller = BehaviorSubject<List<Video>>();
  Stream<List<Video>> get mapVideosStream => _mapVideosStreamConntroller.stream;

  final Map<String, VideoDetail> _videoDetails = {};
  final _videoDetailStreamController = BehaviorSubject<VideoDetail?>();
  Stream<VideoDetail?> get videoDetailStream =>
      _videoDetailStreamController.stream;

  @visibleForTesting
  final Map<String, ProfileDetail> profileDetailsCache = {};
  final _profileStreamController =
      BehaviorSubject<Map<String, ProfileDetail>>();
  Stream<Map<String, ProfileDetail>> get profileStream =>
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

  /// Return userId or null
  String? get userId => _supabaseClient.auth.currentUser?.id;

  /// Completes when auth state is known
  Completer<void> statusKnown = Completer<void>();

  /// Completes when userId is known
  Completer<void> uidKnown = Completer<void>();

  /// The user's profile
  Profile? get myProfile => profileDetailsCache[userId ?? ''];

  /// Whether the user has agreed to terms of service or not
  Future<bool> get hasAgreedToTermsOfService =>
      _localStorage.containsKey(key: _termsOfServiceAgreementKey);

  Future<void> agreedToTermsOfService() =>
      _localStorage.write(key: _termsOfServiceAgreementKey, value: 'true');

  Future<void> setSessionString(String sessionString) =>
      _localStorage.write(key: _persistantSessionKey, value: sessionString);

  Future<void> deleteSession() =>
      _localStorage.delete(key: _persistantSessionKey);

  /// Resets all cache upon identifying the user
  void _resetCache() {
    if (userId != null) {
      if (!uidKnown.isCompleted) {
        uidKnown.complete();
      }
      getMyProfile();
      getNotifications();
      profileDetailsCache.clear();
      _mapVideos.clear();
    }
  }

  void setAuthListenner() {
    _supabaseClient.auth.onAuthStateChange((event, session) {
      _resetCache();
    });
  }

  Future<void> recoverSession() async {
    final jsonStr = await _localStorage.read(key: _persistantSessionKey);
    if (jsonStr == null) {
      await deleteSession();
      if (!statusKnown.isCompleted) {
        statusKnown.complete();
      }
      return null;
    }

    final res = await _supabaseClient.auth.recoverSession(jsonStr);
    final error = res.error;
    if (error != null) {
      await deleteSession();
      if (!statusKnown.isCompleted) {
        statusKnown.complete();
      }
      throw PlatformException(code: 'login error', message: error.message);
    }
    final session = res.data;
    if (session == null) {
      await deleteSession();
      if (!statusKnown.isCompleted) {
        statusKnown.complete();
      }
      return null;
    }
    _resetCache();

    await setSessionString(session.persistSessionString);
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

  Future<Profile?> getMyProfile() async {
    final userId = this.userId;
    if (userId == null) {
      throw PlatformException(code: 'not signed in ', message: 'Not signed in');
    }
    try {
      await getProfileDetail(userId);
    } catch (e) {
      print(e.toString());
    }
    if (!statusKnown.isCompleted) {
      statusKnown.complete();
    }
  }

  Future<void> getVideosFromLocation(LatLng location) async {
    late final PostgrestResponse res;
    if (userId != null) {
      res = await _supabaseClient
          .rpc('nearby_videos', params: {
            'location': 'POINT(${location.longitude} ${location.latitude})',
            'user_id': userId!,
          })
          .limit(5)
          .execute();
    } else {
      res = await _supabaseClient
          .rpc('anonymous_nearby_videos', params: {
            'location': 'POINT(${location.longitude} ${location.latitude})'
          })
          .limit(5)
          .execute();
    }
    final error = res.error;
    final data = res.data;
    if (error != null) {
      throw PlatformException(code: 'getVideosFromLocation error');
    } else if (data == null) {
      throw PlatformException(code: 'getVideosFromLocation error null data');
    }
    final videoIds = _mapVideos.map((video) => video.id);
    final newVideos = Video.videosFromData(data: data, userId: userId)
        .where((video) => !videoIds.contains(video.id));
    _mapVideos.addAll(newVideos);
    _mapVideosStreamConntroller.sink.add(_mapVideos);
  }

  Future<void> getVideosInBoundingBox(LatLngBounds bounds) async {
    late final PostgrestResponse res;
    if (userId != null) {
      res = await _supabaseClient.rpc('videos_in_bouding_box', params: {
        'min_lng': '${bounds.southwest.longitude}',
        'min_lat': '${bounds.southwest.latitude}',
        'max_lng': '${bounds.northeast.longitude}',
        'max_lat': '${bounds.northeast.latitude}',
        'user_id': userId!,
      }).execute();
    } else {
      res =
          await _supabaseClient.rpc('anonymous_videos_in_bouding_box', params: {
        'min_lng': '${bounds.southwest.longitude}',
        'min_lat': '${bounds.southwest.latitude}',
        'max_lng': '${bounds.northeast.longitude}',
        'max_lat': '${bounds.northeast.latitude}',
      }).execute();
    }
    final error = res.error;
    final data = res.data;
    if (error != null) {
      throw PlatformException(code: 'getVideosFromLocation error');
    } else if (data == null) {
      throw PlatformException(code: 'getVideosFromLocation error null data');
    }
    final videoIds = _mapVideos.map((video) => video.id);
    final newVideos = Video.videosFromData(data: data, userId: userId)
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
    if (error != null) {
      throw PlatformException(code: 'getVideosFromUid error');
    }
    final data = res.data;
    if (data == null) {
      throw PlatformException(code: 'getVideosFromUid error');
    }
    return Video.videosFromData(data: data, userId: userId);
  }

  Future<List<Video>> getLikedPostsFromUid(String uid) async {
    final res = await _supabaseClient
        .from('liked_videos')
        .select()
        .eq('liked_by', uid)
        .order('liked_at')
        .execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(code: 'getLikedPostsFromUid error');
    }
    final data = res.data;
    if (data == null) {
      throw PlatformException(code: 'getLikedPostsFromUid error');
    }
    return Video.videosFromData(data: data, userId: userId);
  }

  Future<Profile?> getProfileDetail(String targetUid) async {
    if (profileDetailsCache[targetUid] != null) {
      return profileDetailsCache[targetUid];
    }
    late final PostgrestResponse res;
    res = await _supabaseClient.rpc('profile_detail', params: {
      'my_user_id': userId ?? _anonymousUUID,
      'target_user_id': targetUid,
    }).execute();

    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Database_Error',
        message: error.message,
      );
    }
    final data = res.data as List;

    if (data.isEmpty) {
      throw PlatformException(
          code: error?.code ?? 'No User',
          message: error?.message ?? 'Could not find the user. ');
    }

    final profile = ProfileDetail.fromData(data[0]);
    profileDetailsCache[targetUid] = profile;
    _profileStreamController.sink.add(profileDetailsCache);
    return profile;
  }

  Future<void> saveProfile({required Profile profile}) async {
    final res =
        await _supabaseClient.from('users').upsert(profile.toMap()).execute();
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
    late final ProfileDetail newProfile;
    if (profileDetailsCache[userId!] != null) {
      newProfile = profileDetailsCache[userId!]!.copyWith(
        name: profile.name,
        description: profile.description,
        imageUrl: profile.imageUrl,
      );
    } else {
      // When the user initially registered
      newProfile = ProfileDetail(
        id: userId!,
        name: profile.name,
        description: profile.description,
        imageUrl: profile.imageUrl,
        followerCount: 0,
        followingCount: 0,
        likeCount: 0,
        isFollowing: true,
      );
    }
    profileDetailsCache[userId!] = newProfile;
    _profileStreamController.add(profileDetailsCache);
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
    final urlRes = _supabaseClient.storage.from(bucket).getPublicUrl(path);
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
    final userId = _supabaseClient.auth.currentUser?.id;
    late final PostgrestResponse res;
    if (userId != null) {
      res = await _supabaseClient.rpc('get_video_detail',
          params: {'video_id': videoId, 'user_id': userId}).execute();
    } else {
      res = await _supabaseClient.rpc('anonymous_get_video_detail',
          params: {'video_id': videoId}).execute();
    }
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
    var videoDetail = VideoDetail.fromData(
        data: Map.from(List.from(data).first), userId: userId);
    if (videoDetail.location != null) {
      final locationString = await _locationToString(videoDetail.location!);
      videoDetail = videoDetail.copyWith(locationString: locationString);
    }
    _videoDetails[videoId] = videoDetail;
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);
    await _analytics.logEvent(name: 'view_video', parameters: {
      'video_id': videoId,
    });
  }

  Future<void> like(Video video) async {
    final videoId = video.id;
    final currentVideoDetail = _videoDetails[videoId]!;
    _videoDetails[videoId] = currentVideoDetail.copyWith(
        likeCount: (currentVideoDetail.likeCount + 1), haveLiked: true);
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);

    if (profileDetailsCache[video.userId] != null) {
      // Increment the like count of liked user by 1
      profileDetailsCache[video.userId] = profileDetailsCache[video.userId]!
          .copyWith(
              likeCount: profileDetailsCache[video.userId]!.likeCount + 1);
      _profileStreamController.add(profileDetailsCache);
    }

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

  Future<void> unlike(Video video) async {
    final videoId = video.id;
    final currentVideoDetail = _videoDetails[videoId]!;
    _videoDetails[videoId] = currentVideoDetail.copyWith(
        likeCount: (currentVideoDetail.likeCount - 1), haveLiked: false);
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);

    if (profileDetailsCache[video.userId] != null) {
      // Decrement the like count of liked user by 1
      profileDetailsCache[video.userId] = profileDetailsCache[video.userId]!
          .copyWith(
              likeCount: profileDetailsCache[video.userId]!.likeCount - 1);
      _profileStreamController.add(profileDetailsCache);
    }

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
    if (userId == null) {
      // If the user is not signed in, do not emit anything
      return;
    }
    final res = await _supabaseClient
        .from('notifications')
        .select()
        .eq('receiver_user_id', userId)
        .not('action_user_id', 'eq', userId)
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

    Future<AppNotification> _replaceCommentTextWithMentionedUserName(
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
        _notifications.map(_replaceCommentTextWithMentionedUserName));
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
    return Video.videosFromData(data: data, userId: userId);
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
        .ilike('name', '%$queryString%')
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
    return profiles;
  }

  List<Profile> getMentionedProfiles(String commentText) {
    final userNames = commentText
        .split(' ')
        .where((word) => word.isNotEmpty && word[0] == '@')
        .map((word) => RegExp(r'^\w*').firstMatch(word.substring(1))!.group(0)!)
        .toList();
    final userNameMap = <String, Profile>{}..addEntries(
        profileDetailsCache.values.map<MapEntry<String, Profile>>(
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
      return '@';
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
    await Future.wait(
        getUserIdsInComment(comment).map(getProfileDetail).toList());
    final regExp = RegExp(
        r'@[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b');
    final replacedComment = comment.replaceAllMapped(regExp, (match) {
      final key = match.group(0)!.substring(1);
      final name = profileDetailsCache[key]?.name;

      /// Return the original id if no profile was found with the id
      return '@${name ?? match.group(0)!.substring(1)}';
    });
    return replacedComment;
  }

  double getZIndex(DateTime createdAt) {
    return max((createdAt.millisecondsSinceEpoch ~/ 1000000 - 1600000), 0)
        .toDouble();
  }

  Future<File?> getVideoFile() async {
    try {
      final pickedVideo =
          await ImagePicker().getVideo(source: ImageSource.gallery);
      if (pickedVideo != null) {
        return File(pickedVideo.path);
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<LatLng?> getVideoLocation(String videoPath) async {
    final videoInfo = await FlutterVideoInfo().getVideoInfo(videoPath);
    final locationString = videoInfo?.location;
    if (locationString != null) {
      print(locationString);
      final matches = RegExp(r'(\+|\-)(\d*\.?\d*)').allMatches(locationString);
      final lat = double.parse(matches.elementAt(0).group(0)!);
      final lng = double.parse(matches.elementAt(1).group(0)!);
      return LatLng(lat, lng);
    }
  }

  Future<List<Video>> getNewVideos() async {
    final res = await _supabaseClient
        .from('videos')
        .select(
            'id, url, image_url, thumbnail_url, gif_url, description, user_id, created_at')
        .order('created_at')
        .limit(24)
        .execute();
    if (res.error != null) {
      throw PlatformException(
          code: 'NewVideos', message: 'Error loading new videos');
    }
    final videos = Video.videosFromData(data: res.data!, userId: userId);
    return videos;
  }

  Future<void> follow(String followedUid) async {
    if (userId == null) {
      return;
    }
    if (profileDetailsCache[followedUid] != null) {
      profileDetailsCache[followedUid] =
          profileDetailsCache[followedUid]!.copyWith(isFollowing: true);
    }
    if (profileDetailsCache[userId!] != null) {
      // Update your own follow count
      profileDetailsCache[userId!] = profileDetailsCache[userId!]!.copyWith(
          followingCount: profileDetailsCache[userId!]!.followingCount + 1);
    }
    if (profileDetailsCache[followedUid] != null) {
      // Update the follow count of the user who have been followed
      profileDetailsCache[followedUid] = profileDetailsCache[followedUid]!
          .copyWith(
              followerCount:
                  profileDetailsCache[followedUid]!.followerCount + 1);
    }
    _profileStreamController.add(profileDetailsCache);
    await _supabaseClient.from('follow').insert({
      'following_user_id': userId,
      'followed_user_id': followedUid,
    }).execute();
  }

  Future<void> unfollow(String followedUid) async {
    if (userId == null) {
      return;
    }
    if (profileDetailsCache[followedUid] != null) {
      profileDetailsCache[followedUid] =
          profileDetailsCache[followedUid]!.copyWith(isFollowing: false);
    }
    if (profileDetailsCache[userId!] != null) {
      // Update the user's follow count
      profileDetailsCache[userId!] = profileDetailsCache[userId!]!.copyWith(
          followingCount: profileDetailsCache[userId!]!.followingCount - 1);
    }
    if (profileDetailsCache[followedUid] != null) {
      // update the follow count of the user who have been followed
      profileDetailsCache[followedUid] = profileDetailsCache[followedUid]!
          .copyWith(
              followerCount:
                  profileDetailsCache[followedUid]!.followerCount - 1);
    }
    _profileStreamController.add(profileDetailsCache);
    await _supabaseClient
        .from('follow')
        .delete()
        .eq('following_user_id', userId)
        .eq('followed_user_id', followedUid)
        .execute();
  }

  Future<String> _locationToString(LatLng location) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isEmpty) {
        return 'Unknown';
      }
      if (placemarks.first.administrativeArea?.isEmpty == true) {
        return '${placemarks.first.name}';
      }
      return '${placemarks.first.administrativeArea}, ${placemarks.first.country}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<List<Profile>> getFollowers(String uid) async {
    late final PostgrestResponse res;
    // get followers of uid with is_following
    res = await _supabaseClient.rpc('followers', params: {
      'my_user_id': userId ?? _anonymousUUID,
      'target_user_id': uid,
    }).execute();

    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'getFollowers',
        message: error.message,
      );
    }
    final data = res.data! as List;
    final profiles = Profile.fromList(List<Map<String, dynamic>>.from(data));
    return profiles;
  }

  Future<List<Profile>> getFollowings(String uid) async {
    late final PostgrestResponse res;
    // get followers of uid with is_following
    res = await _supabaseClient.rpc('followings', params: {
      'my_user_id': userId ?? _anonymousUUID,
      'target_user_id': uid,
    }).execute();

    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'getFollowings',
        message: error.message,
      );
    }
    final data = res.data! as List;
    final profiles = Profile.fromList(List<Map<String, dynamic>>.from(data));
    return profiles;
  }
}
