part of 'profile_cubit.dart';

@immutable

/// Base state for profile
abstract class ProfileState {}

/// Initial state. Indicates that the app is loading the profile
class ProfileLoading extends ProfileState {}

/// State where profile has finished loading.
class ProfileLoaded extends ProfileState {
  /// State where profile has finished loading.
  ProfileLoaded(
    this.profile,
  );

  /// Loaded profile
  final ProfileDetail profile;
}

/// State to be emitted when the target profile was not found.
class ProfileNotFound extends ProfileState {}

/// State to be emitted when an error occurs while loading profile.
class ProfileError extends ProfileState {}

/// State to be emitted when an followers or followings were loaded
class FollowerOrFollowingLoaded extends ProfileState {
  /// State to be emitted when an followers or followings were loaded
  FollowerOrFollowingLoaded(this.followingOrFollower);

  /// List of followers or followings
  final List<Profile> followingOrFollower;
}
