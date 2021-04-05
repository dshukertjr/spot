part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  ProfileLoaded(this.profile);

  final Profile profile;
}

class ProfileNotFound extends ProfileState {}
