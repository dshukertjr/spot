import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required Repository repository,
  })   : _repository = repository,
        super(ProfileLoading());

  final Repository _repository;

  Future<void> loadProfile(String uid) async {
    try {
      final profile = await _repository.getProfile(uid);
      if (profile == null) {
        emit(ProfileNotFound());
        return;
      }
      emit(ProfileLoaded(profile));
    } catch (err) {
      emit(ProfileError());
    }
  }

  Future<void> saveProfile({
    required String name,
    required String description,
    required File? imageFile,
  }) async {
    try {
      emit(ProfileLoading());
      final userId = _repository.userId;
      if (userId == null) {
        throw PlatformException(
          code: 'Auth_Error',
          message: 'Session has expired',
        );
      }
      String? imageUrl;
      if (imageFile != null) {
        final videoImagePath = '$userId/profile.${imageFile.path.split('.').last}';
        imageUrl = await _repository.uploadFile(
          bucket: 'profiles',
          file: imageFile,
          path: videoImagePath,
        );
      }

      final profile = await _repository.saveProfile(
        map: Profile.toMap(
          id: userId,
          name: name,
          description: description,
          imageUrl: imageUrl,
        ),
        userId: userId,
      );
      emit(ProfileLoaded(profile));
    } catch (err) {
      emit(ProfileError());
    }
  }
}
