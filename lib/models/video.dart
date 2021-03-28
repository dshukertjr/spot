import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/models/profile.dart';

class Video {
  Video({
    required this.id,
    required this.videoUrl,
    required this.videoImageUrl,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.description,
    required this.createdBy,
    required this.position,
  });

  final String id;
  final String videoUrl;
  final String videoImageUrl;
  final String thumbnailUrl;
  final DateTime createdAt;
  final String description;
  final Profile createdBy;
  final LatLng position;

  Future<double> getDistanceInMeter() async {
    return 1000;
  }
}
