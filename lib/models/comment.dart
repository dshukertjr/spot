class Comment {
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.videoId,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final String videoId;
}
