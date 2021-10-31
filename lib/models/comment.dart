import 'package:spot/models/profile.dart';

/// Represents a single comment created by a user.
class Comment {
  /// Represents a single comment created by a user.
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.videoId,
    required this.user,
  });

  /// ID of the comment.
  final String id;

  /// Text of the comment.
  final String text;

  /// Create date of the comment.
  final DateTime createdAt;

  /// ID of the video that the comment was posted.
  final String videoId;

  /// Profile data of the user who posted this comment.
  final Profile user;

  /// Converts raw data loaded from Supabase `comments` table
  /// to list of comments.
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

  /// Returns a Map of comment data.
  ///
  /// Used when composing a new comment.
  static Map<String, dynamic> create(
      {required String text, required String userId, required String videoId}) {
    return {
      'text': text,
      'video_id': videoId,
      'user_id': userId,
    };
  }

  /// Creates a new instance of `Comment` while copying certain properties.
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
