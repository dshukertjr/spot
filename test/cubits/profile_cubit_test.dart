import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/models/profile.dart';

import '../helpers/helpers.dart';
import '../test_resources/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue<Profile>(sampleProfile);
  });

  test('Initial State', () {
    final repository = MockRepository();
    expect(ProfileCubit(repository: repository).state is ProfileLoading, true);
  });

  group('ProfileCubit getProfile()', () {
    blocTest<ProfileCubit, ProfileState>(
      'Can load profile',
      build: () {
        final repository = MockRepository();
        when(() => repository.getProfileDetail('aaa'))
            .thenAnswer((_) => Future.value(sampleProfile));
        when(() => repository.profileStream)
            .thenAnswer((_) => Stream.value({'aaa': sampleProfileDetail}));
        return ProfileCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadProfile('aaa');
      },
      expect: () => [
        isA<ProfileLoaded>(),
      ],
    );
    blocTest<ProfileCubit, ProfileState>(
      'Will emit profile not found when the target profile is missing',
      build: () {
        final repository = MockRepository();
        when(() => repository.getProfileDetail('aaa'))
            .thenAnswer((_) => Future.value());
        when(() => repository.profileStream)
            .thenAnswer((_) => Stream.value({'bbb': otherProfileDetail}));
        return ProfileCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadProfile('aaa');
      },
      expect: () => [
        isA<ProfileNotFound>(),
      ],
    );
    blocTest<ProfileCubit, ProfileState>(
      'Emits error when profile not found',
      build: () {
        final repository = MockRepository();
        when(() => repository.getProfileDetail('aaa'))
            .thenThrow(PlatformException(code: ''));
        return ProfileCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.loadProfile('aaa');
      },
      expect: () => [
        isA<ProfileError>(),
      ],
    );
  });

  group('ProfileCubit saveProfile()', () {
    final testFile = File('test_resources/user.png');

    blocTest<ProfileCubit, ProfileState>(
      'Can save profile without profile image',
      build: () {
        final repository = MockRepository();
        when(() => repository.userId).thenReturn('aaa');
        when(() => repository.saveProfile(profile: any(named: 'profile')))
            .thenAnswer((_) => Future.value(sampleProfile));
        return ProfileCubit(repository: repository);
      },
      seed: () => ProfileLoaded(sampleProfileDetail),
      act: (cubit) async {
        await cubit.saveProfile(name: '', description: '', imageFile: null);
      },
      expect: () => [
        isA<ProfileLoading>(),
      ],
    );
    blocTest<ProfileCubit, ProfileState>(
      'Can save profile with profile image',
      build: () {
        final repository = MockRepository();
        when(() => repository.userId).thenReturn('aaa');
        when(() => repository.saveProfile(profile: any(named: 'profile')))
            .thenAnswer((_) => Future.value(sampleProfile));
        when(() => repository.uploadFile(
              bucket: any(named: 'bucket'),
              path: any(named: 'path'),
              file: testFile,
            )).thenAnswer((invocation) => Future.value(''));
        return ProfileCubit(repository: repository);
      },
      seed: () => ProfileLoaded(sampleProfileDetail),
      act: (cubit) async {
        await cubit.saveProfile(name: '', description: '', imageFile: testFile);
      },
      expect: () => [
        isA<ProfileLoading>(),
      ],
    );
    blocTest<ProfileCubit, ProfileState>(
      'Will emit error state when userId is null',
      build: () {
        final repository = MockRepository();
        when(() => repository.userId).thenReturn(null);
        return ProfileCubit(repository: repository);
      },
      seed: () => ProfileLoaded(sampleProfileDetail),
      act: (cubit) async {
        await cubit.saveProfile(name: '', description: '', imageFile: null);
      },
      expect: () => [
        isA<ProfileError>(),
      ],
    );
  });
}
