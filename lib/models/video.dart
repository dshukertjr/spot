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
    required this.createdBy,
    required this.location,
  });

  final String id;
  final String url;
  final String imageUrl;
  final String thumbnailUrl;
  final String gifUrl;
  final DateTime createdAt;
  final String description;
  final Profile createdBy;
  final LatLng location;

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
      'url': videoUrl,
      'image_url': videoImageUrl,
      'thumbnail_url': thumbnailUrl,
      'gif_url': gifUrl,
      'description': description,
      'user_id': creatorUid,
      'location': 'POINT(${location.latitude} ${location.longitude})',
    };
  }

  static List<Video> videosFromData(List<dynamic> data) {
    return data
        .map<Video>((res) => Video(
              id: res['id'] as String,
              url: res['url'] as String,
              imageUrl: res['mage_url'] as String,
              thumbnailUrl: res['thumbnail_url'] as String,
              gifUrl: res['gif_url'] as String,
              description: res['description'] as String,
              createdBy: Profile(
                id: res['user_id'] as String,
                name: res['user_name'] as String,
                description: res['user_description'] as String,
                imageUrl: res['user_image_description'] as String,
              ),
              location: _locationFromPoint(res['location'] as String),
              createdAt: DateTime.parse(res['created_at'] as String),
            ))
        .toList();
  }

  static Video videoFromData(Map<String, dynamic> data) {
    return Video(
      id: data['id'] as String,
      url: data['url'] as String,
      imageUrl: data['image_rl'] as String,
      thumbnailUrl: data['thumbnail_url'] as String,
      gifUrl: data['gif_url'] as String,
      description: data['description'] as String,
      createdBy: Profile(
        id: data['user_id'] as String,
        name: data['user_name'] as String,
        imageUrl: data['user_image_url'] as String,
        description: data['user_description'] as String,
      ),
      location: _locationFromPoint(data['location'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  static LatLng _locationFromPoint(String point) {
    final splits =
        point.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    return LatLng(double.parse(splits.first), double.parse(splits.last));
  }
}
