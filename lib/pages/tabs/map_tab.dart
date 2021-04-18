import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/cubits/videos/videos_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/repositories/repository.dart';

import '../../cubits/videos/videos_cubit.dart';

class MapTab extends StatelessWidget {
  const MapTab({Key? key, required GlobalKey<MapState> mapKey})
      : _mapKey = mapKey,
        super(key: key);

  static Widget create(
    GlobalKey<MapState> mapKey,
  ) {
    return BlocProvider<VideosCubit>(
      create: (context) => VideosCubit(
        databaseRepository: RepositoryProvider.of<Repository>(context),
      )..loadInitialVideos(),
      child: MapTab(mapKey: mapKey),
    );
  }

  final GlobalKey<MapState> _mapKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
      builder: (context, state) {
        if (state is VideosInitial) {
          return preloader;
        } else if (state is VideosLoading) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _Map(
                key: _mapKey,
                location: state.location,
              ),
              preloader,
            ],
          );
        } else if (state is VideosLoaded) {
          return _Map(key: _mapKey, videos: state.videos);
        } else if (state is VideosLoadingMore) {
          final videos = state.videos;
          return Stack(
            fit: StackFit.expand,
            children: [
              _Map(
                key: _mapKey,
                videos: videos,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, right: 12),
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: preloader,
                  ),
                ),
              ),
            ],
          );
        }
        throw UnimplementedError();
      },
    );
  }
}

class _Map extends StatefulWidget {
  _Map({
    Key? key,
    List<Video>? videos,
    LatLng? location,
  })  : _videos = videos ?? [],
        _location = location ?? const LatLng(0, 0),
        super(key: key);

  final List<Video> _videos;
  final LatLng _location;

  @override
  MapState createState() => MapState();
}

class MapState extends State<_Map> {
  final Completer<GoogleMapController> _controller = Completer();

  /// Holds all the markers for the map
  var _markers = <Marker>{};

  /// false if there hasn't been marker being loaded yet
  var _hasLoadedMarkers = false;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: _markers,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      initialCameraPosition: CameraPosition(
        target: widget._location,
        zoom: 16,
      ),
      onCameraIdle: () async {
        // Finds the center of the map and load videos around that location
        final controller = await _controller.future;
        final bounds = await controller.getVisibleRegion();
        final center = LatLng((bounds.northeast.latitude + bounds.southwest.latitude) / 2,
            (bounds.northeast.longitude + bounds.southwest.longitude) / 2);
        return BlocProvider.of<VideosCubit>(context).loadFromLocation(center);
      },
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle(
            '[{"featureType":"all","elementType":"geometry","stylers":[{"color":"#202c3e"}]},{"featureType":"all","elementType":"labels.text","stylers":[{"visibility":"off"}]},{"featureType":"all","elementType":"labels.text.fill","stylers":[{"gamma":0.01},{"lightness":20},{"weight":"1.39"},{"color":"#ffffff"},{"visibility":"off"}]},{"featureType":"all","elementType":"labels.text.stroke","stylers":[{"weight":"0.96"},{"saturation":"9"},{"visibility":"off"},{"color":"#000000"}]},{"featureType":"all","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"geometry","stylers":[{"lightness":30},{"saturation":"9"},{"color":"#273556"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"saturation":20}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"lightness":20},{"saturation":-20}]},{"featureType":"road","elementType":"geometry","stylers":[{"lightness":10},{"saturation":-30}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#3f499d"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"saturation":25},{"lightness":25},{"weight":"0.01"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#ff0000"}]},{"featureType":"water","elementType":"all","stylers":[{"lightness":-20}]}]');
        _controller.complete(controller);
      },
    );
  }

  @override
  void didUpdateWidget(covariant _Map oldWidget) {
    _createMarkers(videos: widget._videos, context: context)
        .then((_) => _moveCameraToShowAllMarkers());
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _moveCameraToShowAllMarkers() async {
    if (_markers.isEmpty) {
      return;
    }
    if (_hasLoadedMarkers) {
      return;
    }
    _hasLoadedMarkers = true;
    final controller = await _controller.future;
    if (_markers.length == 1) {
      // If there is only 1 marker, move camera to centre that marker
      await controller.moveCamera(CameraUpdate.newLatLng(_markers.first.position));
    }
    final cordinatesList = List<LatLng>.from(_markers.map((marker) => marker.position))
      ..sort((a, b) => b.latitude.compareTo(a.latitude));
    final northernLatitude = cordinatesList.first.latitude;
    cordinatesList.sort((a, b) => a.latitude.compareTo(b.latitude));
    final southernLatitude = cordinatesList.first.latitude;
    cordinatesList.sort((a, b) => b.longitude.compareTo(a.longitude));
    final easternLongitude = cordinatesList.first.longitude;
    cordinatesList.sort((a, b) => a.longitude.compareTo(b.longitude));
    final westernLongitude = cordinatesList.first.longitude;
    final bounds = LatLngBounds(
      northeast: LatLng(northernLatitude, easternLongitude),
      southwest: LatLng(southernLatitude, westernLongitude),
    );
    return controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20));
  }

  Future<void> _createMarkers({
    required List<Video> videos,
    required BuildContext context,
  }) async {
    /// Only create markers for videos that the marker does not exist yet.
    final markerIds = _markers.toList().map((marker) => marker.markerId.value).toList();
    final newVideos = videos.where((video) => !markerIds.contains(video.id));
    final newMarkers = await Future.wait(
      newVideos.map<Future<Marker>>(
        (video) => _createMarkerImageFromAsset(video: video, context: context),
      ),
    );

    /// Delete marker for videos that is not included in videos
    final videoIds = videos.map((video) => video.id).toList();
    _markers.removeWhere((marker) => !videoIds.contains(marker.markerId.value));

    if (newMarkers.isNotEmpty) {
      setState(() {
        _markers.addAll(newMarkers.toSet());
      });
    }
  }

  Future<Marker> _createMarkerImageFromAsset({
    required Video video,
    required BuildContext context,
  }) async {
    const markerSize = 100.0;
    const lifeTimeIndicatorWidth = 6.0;

    var onTap = () {
      Navigator.of(context).push(
        ViewVideoPage.route(video.id),
      );
    };

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    var factor = 1;
    if (devicePixelRatio >= 1.5) {
      factor = 2;
    } else if (devicePixelRatio >= 2.5) {
      factor = 3;
    } else if (devicePixelRatio >= 3.5) {
      factor = 4;
    }

    final size = markerSize * factor;
    final imagePadding = lifeTimeIndicatorWidth * factor;
    final imageSize = size - imagePadding * 2;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final boundingRect = Rect.fromLTWH(0.0, 0.0, size, size);

    /// Adding gradient to the background of the marker
    final paint = Paint();
    if (video.id == 'aaa') {
      paint.shader = blueGradient.createShader(
        boundingRect,
      );
    } else {
      paint.shader = redOrangeGradient.createShader(
        boundingRect,
      );
    }

    // start adding images
    final res = await http.get(Uri.parse(video.thumbnailUrl));
    final imageBytes = res.bodyBytes;
    final imageCodec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: imageSize.toInt(),
      targetHeight: imageSize.toInt(),
    );
    final frameInfo = await imageCodec.getNextFrame();
    final byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      throw PlatformException(code: 'byteData null', message: 'byteData is null');
    }
    final resizedMarkerImageBytes = byteData.buffer.asUint8List();
    final image = await _loadImage(Uint8List.view(resizedMarkerImageBytes.buffer));

    //start adding duration indicator
    canvas
      ..drawCircle(Offset(size / 2, size / 2), size / 2, paint)
      ..saveLayer(boundingRect, paint)
      ..drawCircle(Offset(size / 2, size / 2), imageSize / 2, paint)
      ..drawImage(image, Offset(imagePadding, imagePadding), paint..blendMode = BlendMode.srcIn)
      ..restore();

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());

    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw PlatformException(
        code: 'marker error',
        message: 'Error while creating byteData',
      );
    }
    final markerIcon = data.buffer.asUint8List();

    return Marker(
      anchor: const Offset(0.5, 0.5),
      onTap: onTap,
      consumeTapEvents: true,
      markerId: MarkerId(video.id),
      position: video.location!,
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );
  }

  Future<ui.Image> _loadImage(Uint8List img) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img, completer.complete);
    return completer.future;
  }
}
