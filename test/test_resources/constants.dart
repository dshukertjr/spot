import 'package:spot/models/profile.dart';

final sampleProfile = Profile(
  id: 'aaa',
  name: 'name',
  description: 'description',
);
final otherProfile = Profile(
  id: 'bbb',
  name: 'otherName',
  description: 'something different',
);

final sampleProfileDetail = ProfileDetail(
  id: 'aaa',
  name: 'name',
  description: 'description',
  followerCount: 0,
  followingCount: 0,
  likeCount: 0,
  isFollowing: false,
);

final otherProfileDetail = ProfileDetail(
  id: 'bbb',
  name: 'otherName',
  description: 'something different',
  followerCount: 0,
  followingCount: 0,
  likeCount: 0,
  isFollowing: false,
);
