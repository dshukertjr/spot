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
              createdAt: DateTime.parse(row['createdAt'] as String),
              videoId: row['videoId'] as String,
              user: Profile(
                id: row['user_id'] as String,
                name: row['name'] as String,
                description: row['description'] as String?,
                imageUrl: row['imageUrl'] as String?,
              ),
            ))
        .toList();
  }
}
