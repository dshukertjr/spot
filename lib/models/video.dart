import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:spot/models/profile.dart';

class Video {
  Video({
    required this.id,
    required this.url,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.gifUrl,
    required this.createdAt,
    required this.description,
    required this.userId,
    required this.location,
  });

  final String id;
  final String url;
  final String imageUrl;
  final String thumbnailUrl;
  final String gifUrl;
  final DateTime createdAt;
  final String description;
  final String userId;
  final LatLng? location;

  Future<double> getDistanceInMeter() async {
    return 1000;
  }

  static Video creation({
    required String videoUrl,
    required String videoImageUrl,
    required String thumbnailUrl,
    required String gifUrl,
    required String description,
    required String creatorUid,
    required LatLng location,
  }) {
    return Video(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: videoUrl,
      imageUrl: videoImageUrl,
      thumbnailUrl: thumbnailUrl,
      gifUrl: gifUrl,
      description: description,
      userId: creatorUid,
      location: location,
      createdAt: DateTime.now(),
    );
  }

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
      location: location,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'gif_url': gifUrl,
      'description': description,
      'user_id': userId,
      if (location != null)
        'location': 'POINT(${location!.longitude} ${location!.latitude})',
    };
  }

  static List<Video> videosFromData(List<dynamic> data) {
    return data
        .map<Video>((row) => Video(
              id: row['id'] as String,
              url: row['url'] as String,
              imageUrl: row['image_url'] as String,
              thumbnailUrl: row['thumbnail_url'] as String,
              gifUrl: row['gif_url'] as String,
              description: row['description'] as String,
              userId: row['user_id'] as String,
              location: row['location'] == null
                  ? null
                  : _locationFromPoint(row['location'] as String),
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }

  static LatLng _locationFromPoint(String point) {
    final splits =
        point.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    return LatLng(double.parse(splits.last), double.parse(splits.first));
  }
}

class VideoDetail extends Video {
  VideoDetail({
    required String id,
    required String url,
    required String imageUrl,
    required String thumbnailUrl,
    required String gifUrl,
    required DateTime createdAt,
    required String description,
    required LatLng location,
    required String userId,
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
          location: location,
        );

  final int likeCount;
  final int commentCount;
  final bool haveLiked;
  final Profile createdBy;

  /// String representitive of the location
  /// e.g. NewYork, USA
  final String? locationString;

  static VideoDetail fromData(Map<String, dynamic> data) {
    return VideoDetail(
      id: data['id'] as String,
      url: data['url'] as String,
      imageUrl: data['image_url'] as String,
      thumbnailUrl: data['thumbnail_url'] as String,
      gifUrl: data['gif_url'] as String,
      description: data['description'] as String,
      userId: data['user_id'] as String,
      createdBy: Profile(
        id: data['user_id'] as String,
        name: data['user_name'] as String,
        imageUrl: data['user_image_url'] as String?,
        description: data['user_description'] as String?,
      ),
      location: Video._locationFromPoint(data['location'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
      likeCount: data['like_count'] as int,
      commentCount: data['comment_count'] as int,
      haveLiked: ((data['have_liked'] as int) > 0),
    );
  }

  static Map<String, dynamic> like({
    required String videoId,
    required String uid,
  }) {
    return {
      'video_id': videoId,
      'user_id': uid,
    };
  }

  VideoDetail copyWith({
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
      createdAt: createdAt,
      createdBy: createdBy,
      description: description,
      gifUrl: gifUrl,
      id: id,
      userId: userId,
      imageUrl: imageUrl,
      location: location!,
      thumbnailUrl: thumbnailUrl,
      url: url,
    );
  }
}
