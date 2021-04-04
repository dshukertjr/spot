import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required Repository databaseRepository,
  })   : _databaseRepository = databaseRepository,
        super(ProfileLoading());

  final Repository _databaseRepository;

  Future<void> loadProfile(String uid) async {
    final profile = await _databaseRepository.getProfile(uid);
    emit(ProfileLoaded(profile));
  }

  Future<void> saveProfile({
    required String name,
    required String description,
    required File? imageFile,
  }) async {
    emit(ProfileLoading());
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      emit(ProfileLoaded(null));
      throw PlatformException(
        code: 'Auth_Error',
        message: 'Session has expired',
      );
    }
    final profile = await _databaseRepository.saveProfile(
      map: Profile.toMap(
        id: user.id,
        name: name,
        description: description,
      ),
      uid: user.id,
    );
    emit(ProfileLoaded(profile));
  }
}
