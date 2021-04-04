import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';

class Repository {
  // Local Cache
  final Map<String, Profile> _profiles = {};
  final Map<String, Video> _videos = {};

  Future<Profile?> getProfile(String uid) async {
    final targetProfile = _profiles[uid];
    if (targetProfile != null) {
      return targetProfile;
    }
    final res =
        await supabaseClient.from('users').select().eq('id', uid).execute();
    final data = res.data as List;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Database_Error',
        message: error.message,
      );
    }

    if (data.isEmpty) {
      return null;
    }

    final profile = Profile.fromData(data[0]);
    _profiles[uid] = profile;
    return profile;
  }

  Future<Profile> saveProfile({
    required Map<String, dynamic> map,
    required String uid,
  }) async {
    final res = await supabaseClient.from('users').insert([map]).execute();
    final data = res.data;
    final error = res.error;
    if (error != null) {
      throw PlatformException(
        code: error.code ?? 'Database_Error',
        message: error.message,
      );
    }
    if (data == null) {
      throw PlatformException(
        code: 'Database_Error',
        message: 'Error occured while saving profile',
      );
    }

    final profile = Profile.fromData(data[0]);
    _profiles[uid] = profile;
    return profile;
  }

  Future<LatLng> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LatLng(37.43296265331129, -122.08832357078792);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return const LatLng(37.43296265331129, -122.08832357078792);
      }

      if (permission == LocationPermission.denied) {
        return const LatLng(37.43296265331129, -122.08832357078792);
      }
    }
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }
}
