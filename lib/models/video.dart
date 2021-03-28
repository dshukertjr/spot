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
  });

  final String id;
  final String videoUrl;
  final String videoImageUrl;
  final String thumbnailUrl;
  final DateTime createdAt;
  final String description;
  final Profile createdBy;

  Future<double> getDistanceInMeter() async {
    return 1000;
  }
}
