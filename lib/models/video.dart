import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/models/profile.dart';

class Video {
  Video({
    required this.id,
    required this.videoUrl,
    required this.videoImageUrl,
    required this.thumbnailUrl,
    required this.gifUrl,
    required this.createdAt,
    required this.description,
    required this.createdBy,
    required this.position,
  });

  final String id;
  final String videoUrl;
  final String videoImageUrl;
  final String thumbnailUrl;
  final String gifUrl;
  final DateTime createdAt;
  final String description;
  final Profile createdBy;
  final LatLng position;

  Future<double> getDistanceInMeter() async {
    return 1000;
  }

  static Map<String, dynamic> creation({
    required String videoUrl,
    required String videoImageUrl,
    required String thumbnailUrl,
    required String gifUrl,
    required String description,
    required String creatorUid,
    required LatLng location,
  }) {
    return {
      'video_url': videoUrl,
      'video_image_url': videoImageUrl,
      'thumbnail_url': thumbnailUrl,
      'gif_url': gifUrl,
      'description': description,
      'creator_uid': creatorUid,
      'location': 'POINT(${location.latitude} ${location.longitude})',
    };
  }
}
