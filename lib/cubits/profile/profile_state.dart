part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  ProfileLoaded(
    this.profile, {
    this.errorMessage,
  });

  final ProfileDetail profile;
  final String? errorMessage;
}

class ProfileNotFound extends ProfileState {}

class ProfileError extends ProfileState {}
