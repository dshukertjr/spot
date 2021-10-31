import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:spot/models/profile.dart';

/// Class representing a video.
class Video with ClusterItem {
  /// Class representing a video.
  Video({
    required this.id,
    required this.url,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.gifUrl,
    required this.createdAt,
    required this.description,
    required this.userId,
    required this.isFollowing,
    required this.position,
  });

  /// ID of the video.
  final String id;

  /// URL of the video in full size.
  final String url;

  /// URL of the image of the first frame of the video in full size.
  final String imageUrl;

  /// URL of the thumbnail of the first frame of the video.
  final String thumbnailUrl;

  /// URL of the gif of the video. Currently not in use.
  final String gifUrl;

  /// Timestamp of when the video was posted.
  final DateTime createdAt;

  /// Text description of the video.
  /// Used to perform keyword search as well.
  final String description;

  /// ID of the user who have posted the video.
  final String userId;

  /// Whether the logged in user is following the creator of this video.
  final bool isFollowing;

  /// Cordinates of the position of the video.
  final LatLng? position;

  /// Video object to be passed to repository when creating a new video.
  static Video creation({
    required String videoUrl,
    required String videoImageUrl,
    required String thumbnailUrl,
    required String gifUrl,
    required String description,
    required String creatorUid,
    required LatLng position,
  }) {
    return Video(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: videoUrl,
      imageUrl: videoImageUrl,
      thumbnailUrl: thumbnailUrl,
      gifUrl: gifUrl,
      description: description,
      userId: creatorUid,
      position: position,
      isFollowing: false,
      createdAt: DateTime.now(),
    );
  }

  /// CopyWith with only `id`.
  Video updateId({
    String? id,
  }) {
    return Video(
      id: id ?? this.id,
      url: url,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      gifUrl: gifUrl,
      description: description,
      userId: userId,
      position: position,
      isFollowing: false,
      createdAt: createdAt,
    );
  }

  /// Converts a `Video` object to Map so that it can be saved to Supabase.
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'gif_url': gifUrl,
      'description': description,
      'user_id': userId,
      if (position != null)
        'location': 'POINT(${position!.longitude} ${position!.latitude})',
    };
  }

  /// Converts raw data from Supabase to list of `Videos`.
  static List<Video> videosFromData({
    required List<dynamic> data,
    required String? userId,
  }) {
    return data
        .map<Video>((row) => Video(
              id: row['id'] as String,
              url: row['url'] as String,
              imageUrl: row['image_url'] as String,
              thumbnailUrl: row['thumbnail_url'] as String,
              gifUrl: row['gif_url'] as String,
              description: row['description'] as String,
              userId: row['user_id'] as String,
              position: row['location'] == null
                  ? null
                  : _locationFromPoint(row['location'] as String),
              isFollowing: (userId == row['user_id'])
                  ? true
                  : (row['is_following'] ?? false) as bool,
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }

  static LatLng _locationFromPoint(String point) {
    final splits =
        point.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    return LatLng(double.parse(splits.last), double.parse(splits.first));
  }

  @override
  LatLng get location => position!;

  /// Creates a new instance of Video with copying the original
  /// while modifying certain properties.
  Video copyWith({
    String? id,
    String? url,
    String? imageUrl,
    String? thumbnailUrl,
    String? gifUrl,
    DateTime? createdAt,
    String? description,
    String? userId,
    bool? isFollowing,
    LatLng? position,
  }) {
    return Video(
      id: id ?? this.id,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      gifUrl: gifUrl ?? this.gifUrl,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      isFollowing: isFollowing ?? this.isFollowing,
      position: position ?? this.position,
    );
  }
}

/// Class that contains additional details about a video
/// such as number of likes or text representation of the location.
class VideoDetail extends Video {
  /// Class that contains additional details about a video
  /// such as number of likes or text representation of the location.
  VideoDetail({
    required String id,
    required String url,
    required String imageUrl,
    required String thumbnailUrl,
    required String gifUrl,
    required DateTime createdAt,
    required String description,
    required LatLng position,
    required String userId,
    required bool isFollowing,
    required this.likeCount,
    required this.commentCount,
    required this.haveLiked,
    required this.createdBy,
    this.locationString,
  }) : super(
          id: id,
          url: url,
          imageUrl: imageUrl,
          thumbnailUrl: thumbnailUrl,
          gifUrl: gifUrl,
          createdAt: createdAt,
          userId: userId,
          description: description,
          isFollowing: isFollowing,
          position: position,
        );

  /// Number of likes that the video has received.
  final int likeCount;

  /// Number of comments that the video has received.
  final int commentCount;

  /// Whether the logged in user has liked the video or not.
  final bool haveLiked;

  /// Full profile of the user who has posted the video.
  final Profile createdBy;

  /// String representitive of the location
  /// e.g. NewYork, USA
  final String? locationString;

  /// Converts raw data from Supabase to `VideoDetail`
  static VideoDetail fromData({
    required Map<String, dynamic> data,
    required String? userId,
  }) {
    return VideoDetail(
      id: data['id'] as String,
      url: data['url'] as String,
      imageUrl: data['image_url'] as String,
      thumbnailUrl: data['thumbnail_url'] as String,
      gifUrl: data['gif_url'] as String,
      description: data['description'] as String,
      userId: data['user_id'] as String,
      isFollowing: (userId == data['user_id'])
          ? true
          : (data['is_following'] ?? false) as bool,
      createdBy: Profile(
        id: data['user_id'] as String,
        name: data['user_name'] as String,
        imageUrl: data['user_image_url'] as String?,
        description: data['user_description'] as String?,
      ),
      position: Video._locationFromPoint(data['location'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
      likeCount: data['like_count'] as int,
      commentCount: data['comment_count'] as int,
      haveLiked: ((data['have_liked'] as int) > 0),
    );
  }

  /// Creates a map to be saved to `likes` table in Supabase
  /// when the logged in user liked a video.
  static Map<String, dynamic> like({
    required String videoId,
    required String uid,
  }) {
    return {
      'video_id': videoId,
      'user_id': uid,
    };
  }

  @override
  VideoDetail copyWith({
    String? id,
    String? url,
    String? imageUrl,
    String? thumbnailUrl,
    String? gifUrl,
    DateTime? createdAt,
    Profile? createdBy,
    String? description,
    String? userId,
    bool? isFollowing,
    LatLng? position,
    int? likeCount,
    int? commentCount,
    bool? haveLiked,
    String? locationString,
  }) {
    return VideoDetail(
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      haveLiked: haveLiked ?? this.haveLiked,
      locationString: locationString ?? this.locationString,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      description: description ?? this.description,
      gifUrl: gifUrl ?? this.gifUrl,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      position: position ?? this.position!,
      isFollowing: isFollowing ?? this.isFollowing,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      url: url ?? this.url,
    );
  }
}
