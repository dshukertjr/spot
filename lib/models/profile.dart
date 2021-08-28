class Profile {
  Profile({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isFollowing,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isFollowing;

  static Profile fromData(Map<String, dynamic> data) {
    return Profile(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      imageUrl: data['image_url'] as String?,
      isFollowing: ((data['follow'] ?? []) as List).isNotEmpty,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  Profile copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isFollowing,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
