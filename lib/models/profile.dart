class Profile {
  Profile({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  static Profile fromData(Map<String, dynamic> data) {
    return Profile(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      imageUrl: data['image_url'] as String?,
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
}

class ProfileDetail extends Profile {
  ProfileDetail({
    required String id,
    required String name,
    String? description,
    String? imageUrl,
    required this.followerCount,
    required this.followingCount,
    required this.likeCount,
    required this.isFollowing,
  }) : super(
          id: id,
          name: name,
          description: description,
          imageUrl: imageUrl,
        );

  final int followerCount;
  final int followingCount;
  final int likeCount;
  final bool isFollowing;

  static ProfileDetail fromData(Map<String, dynamic> data) {
    return ProfileDetail(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      imageUrl: data['image_url'] as String?,
      followerCount: (data['follower_count'] ?? 0) as int,
      followingCount: (data['following_count'] ?? 0) as int,
      likeCount: (data['like_count'] ?? 0) as int,
      isFollowing: ((data['follow'] ?? []) as List).isNotEmpty,
    );
  }

  ProfileDetail copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? followerCount,
    int? followingCount,
    int? likeCount,
    bool? isFollowing,
  }) {
    return ProfileDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      likeCount: likeCount ?? this.likeCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
