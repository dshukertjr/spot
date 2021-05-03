import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/notification.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:supabase/supabase.dart';

class Repository {
  Repository({required this.supabaseClient});

  final SupabaseClient supabaseClient;

  // Local Cache
  final Map<String, Profile> _profiles = {};
  final List<Video> _mapVideos = [];
  final _mapVideosStreamConntroller = StreamController<List<Video>>.broadcast();

  Stream<List<Video>> get mapVideosStream => _mapVideosStreamConntroller.stream;

  final Map<String, VideoDetail> _videoDetails = {};
  final _videoDetailStreamController = StreamController<VideoDetail?>.broadcast();
  Stream<VideoDetail?> get videoDetailStream => _videoDetailStreamController.stream;

  Future<void> getVideosFromLocation(LatLng location) async {
    final userId = supabaseClient.auth.currentUser!.id;
    final res = await supabaseClient
        .rpc('nearby_videos', params: {
          'location': 'POINT(${location.latitude} ${location.longitude})',
          'user_id': userId,
        })
        .limit(20)
        .execute();
    final error = res.error;
    final data = res.data;
    if (error != null) {
      throw PlatformException(code: 'getVideosFromLocation error');
    } else if (data == null) {
      throw PlatformException(code: 'getVideosFromLocation error null data');
    }
    final videoIds = _mapVideos.map((video) => video.id);
    final newVideos = Video.videosFromData(data).where((video) => !videoIds.contains(video.id));
    _mapVideos.addAll(newVideos);
    _mapVideosStreamConntroller.sink.add(_mapVideos);
  }

  Future<List<Video>> getVideosFromUid(String uid) async {
    final res = await supabaseClient
        .from('videos')
        .select('id, user_id, created_at, url, image_url, thumbnail_url, gif_url, description')
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
    final targetProfile = _profiles[uid];
    if (targetProfile != null) {
      return targetProfile;
    }
    final res = await supabaseClient.from('users').select().eq('id', uid).execute();
    final data = res.data as List;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Database_Error',
        message: error.message,
      );
    }

    if (data.isEmpty) {
      return null;
    }

    final profile = Profile.fromData(data[0]);
    _profiles[uid] = profile;
    return profile;
  }

  Future<Profile> saveProfile({
    required Map<String, dynamic> map,
    required String uid,
  }) async {
    final res = await supabaseClient.from('users').insert([map]).execute();
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

    final profile = Profile.fromData(data[0]);
    _profiles[uid] = profile;
    return profile;
  }

  /// Uploads the video and returns the download URL
  Future<String> uploadFile({
    required String bucket,
    required File file,
    required String path,
  }) async {
    final res = await supabaseClient.storage.from(bucket).upload(path, file);
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.error ?? 'saveVideo',
        message: error.message,
      );
    }
    final urlRes =
        await supabaseClient.storage.from('videos').createSignedUrl(path, 60 * 60 * 24 * 365 * 50);
    final urlError = urlRes.error;
    if (urlError != null) {
      throw PlatformException(
        code: urlError.error ?? 'saveVideo',
        message: urlError.message,
      );
    }
    return urlRes.data!;
  }

  Future<void> saveVideo(Video creatingVideo) async {
    final res = await supabaseClient.from('videos').insert([creatingVideo.toMap()]).execute();
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
  }

  Future<void> getVideoDetailStream(String videoId) async {
    _videoDetailStreamController.sink.add(null);
    final userId = supabaseClient.auth.currentUser!.id;
    final res = await supabaseClient
        .rpc('get_video_detail', params: {'video_id': videoId, 'user_id': userId}).execute();
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
    _videoDetails[videoId] = VideoDetail.fromData(Map.from(List.from(data).first));
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);
  }

  Future<void> like(String videoId) async {
    final currentVideoDetail = _videoDetails[videoId]!;
    _videoDetails[videoId] =
        currentVideoDetail.copyWith(likeCount: (currentVideoDetail.likeCount + 1), haveLiked: true);
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);

    final uid = supabaseClient.auth.currentUser!.id;
    final res = await supabaseClient.from('likes').insert([
      VideoDetail.like(videoId: videoId, uid: uid),
    ]).execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Like Video',
        message: error.message,
      );
    }
  }

  Future<void> unlike(String videoId) async {
    final currentVideoDetail = _videoDetails[videoId]!;
    _videoDetails[videoId] = currentVideoDetail.copyWith(
        likeCount: (currentVideoDetail.likeCount - 1), haveLiked: false);
    _videoDetailStreamController.sink.add(_videoDetails[videoId]!);

    final uid = supabaseClient.auth.currentUser!.id;
    final res = await supabaseClient
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
  }

  Future<List<Comment>> getComments(String videoId) async {
    final res =
        await supabaseClient.from('video_comments').select().eq('video_id', videoId).execute();
    final data = res.data;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Unlike Video',
        message: error.message,
      );
    }
    return Comment.commentsFromData(List.from(data));
  }

  Future<void> comment({
    required String text,
    required String videoId,
  }) async {
    final userId = supabaseClient.auth.currentUser!.id;
    final res = await supabaseClient
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
  }

  Future<List<AppNotification>> getNotifications() async {
    final uid = supabaseClient.auth.currentUser!.id;
    final res = await supabaseClient
        .from('notifications')
        .select()
        .eq('receiver_user_id', uid)
        .limit(50)
        .execute();
    final data = res.data;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Unlike Video',
        message: error.message,
      );
    }
    return AppNotification.fromData(data);
  }

  Future<void> block(String blockedUserId) async {
    final uid = supabaseClient.auth.currentUser!.id;
    final res = await supabaseClient.from('blocks').insert([
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
  }

  Future<void> report({
    required String videoId,
    required String reason,
  }) async {
    final uid = supabaseClient.auth.currentUser!.id;
    final res = await supabaseClient.from('reports').insert([
      {
        'user_id': uid,
        'video_id': videoId,
        'reason': reason,
      }
    ]).execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Unlike Video',
        message: error.message,
      );
    }
  }

  Future<void> delete({required String videoId}) async {
    final res = await supabaseClient.from('videos').delete().eq('id', videoId).execute();
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Delete Video',
        message: error.message,
      );
    }
    _mapVideos.removeWhere((video) => video.id == videoId);
    _mapVideosStreamConntroller.sink.add(_mapVideos);
  }

  Future<List<Video>> search(String queryString) async {
    final res = await supabaseClient
        .from('videos')
        .select('id, url, image_url, thumbnail_url, gif_url, description, user_id, created_at')
        .textSearch('description', queryString, config: 'english')
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
    return Video.videosFromData(data);
  }

  Future<LatLng> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    final result = await Geolocator.requestPermission();
    if (result == LocationPermission.denied || result == LocationPermission.deniedForever) {
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
}
