import 'package:spot/models/profile.dart';

class Video {
  Video({
    required this.videoUrl,
    required this.createdAt,
    required this.description,
    required this.createdBy,
  });

  final String videoUrl;
  final DateTime createdAt;
  final String description;
  final Profile createdBy;
}
