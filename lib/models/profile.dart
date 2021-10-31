/// Class that represents user profile.
class Profile {
  /// Class that represents user profile.
  Profile({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isFollowing = false,
  });

  /// ID of the user.
  final String id;

  /// Name of the user.
  final String name;

  /// Description or bio of the user.
  final String? description;

  /// Profile image URL of the user if present.
  final String? imageUrl;

  /// Whether the logged in user is following this user.
  final bool isFollowing;

  /// Connverts raw data loaded from Supabase to `Profile`.
  static Profile fromData(Map<String, dynamic> data) {
    return Profile(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String,
        imageUrl: data['image_url'] as String?,
        isFollowing: (data['is_following'] ?? false) as bool);
  }

  /// Converts raw data loaded from Supabase to list of `Profile`.
  static List<Profile> fromList(List<Map<String, dynamic>> data) {
    return data.map(fromData).toList();
  }

  /// Converts `Profile` to a map so that it can be save to DB.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  /// Copies and creates a new instance
  /// of `Profile` while replacing some properties.
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

/// Profile with additional information such as like count or follower count.
class ProfileDetail extends Profile {
  /// Profile with additional information such as like count or follower count.
  ProfileDetail({
    required String id,
    required String name,
    String? description,
    String? imageUrl,
    required bool isFollowing,
    required this.followerCount,
    required this.followingCount,
    required this.likeCount,
  }) : super(
          id: id,
          name: name,
          description: description,
          imageUrl: imageUrl,
          isFollowing: isFollowing,
        );

  /// Number of followers that this user has.
  final int followerCount;

  /// Number of users that this user is following.
  final int followingCount;

  /// Number of likes that this user has received.
  final int likeCount;

  /// Converts raw data loaded from Supabase to `ProfileDetail`
  static ProfileDetail fromData(Map<String, dynamic> data) {
    return ProfileDetail(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      imageUrl: data['image_url'] as String?,
      followerCount: (data['follower_count'] ?? 0) as int,
      followingCount: (data['following_count'] ?? 0) as int,
      likeCount: (data['like_count'] ?? 0) as int,
      isFollowing: (data['is_following'] ?? false) as bool,
    );
  }

  @override
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
