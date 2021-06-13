import 'package:spot/models/profile.dart';

class Comment {
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.videoId,
    required this.user,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final String videoId;
  final Profile user;

  static List<Comment> commentsFromData(List<dynamic> data) {
    return data
        .map((row) => Comment(
              id: row['id'] as String,
              text: row['text'] as String,
              createdAt: DateTime.parse(row['created_at'] as String),
              videoId: row['video_id'] as String,
              user: Profile(
                id: row['user_id'] as String,
                name: row['user_name'] as String,
                description: row['user_description'] as String?,
                imageUrl: row['user_image_url'] as String?,
              ),
            ))
        .toList();
  }

  static Map<String, dynamic> create(
      {required String text, required String userId, required String videoId}) {
    return {
      'text': text,
      'video_id': videoId,
      'user_id': userId,
    };
  }

  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? videoId,
    Profile? user,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      videoId: videoId ?? this.videoId,
      user: user ?? this.user,
    );
  }
}
