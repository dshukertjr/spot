import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/gradient_border.dart';
import 'package:spot/cubits/videos/videos_cubit.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/repositories/repository.dart';

import '../../cubits/videos/videos_cubit.dart';

class MapTab extends StatelessWidget {
  const MapTab({Key? key}) : super(key: key);

  static Widget create() {
    return BlocProvider<VideosCubit>(
      create: (context) => VideosCubit(
        repository: RepositoryProvider.of<Repository>(context),
      )..loadInitialVideos(),
      child: const MapTab(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
      builder: (context, state) {
        if (state is VideosInitial) {
          return preloader;
        } else if (state is VideosLoading) {
          return Map(
            location: state.location,
            isLoading: true,
          );
        } else if (state is VideosLoaded) {
          return Map(videos: state.videos);
        } else if (state is VideosLoadingMore) {
          final videos = state.videos;
          return Map(
            videos: videos,
            isLoading: true,
          );
        } else if (state is VideosError) {
          return const Center(child: Text('Something went wrong'));
        }
        throw UnimplementedError();
      },
    );
  }
}

@visibleForTesting
class Map extends StatefulWidget {
  Map({
    Key? key,
    List<Video>? videos,
    LatLng? location,
    bool? isLoading,
  })  : _videos = videos ?? [],
        _location = location ?? const LatLng(0, 0),
        _isLoading = isLoading ?? false,
        super(key: key);

  final List<Video> _videos;
  final LatLng _location;
  final bool _isLoading;

  @override
  MapState createState() => MapState();
}

@visibleForTesting
class MapState extends State<Map> {
  @visibleForTesting
  final Completer<GoogleMapController> controller = Completer();

  /// Holds all the markers for the map
  final _markers = <Marker>{};

  /// false if there hasn't been marker being loaded yet
  var _hasLoadedMarkers = false;

  var _loading = false;

  final TextEditingController _citySearchQueryController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          markers: _markers,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(
            target: widget._location,
            zoom: 16,
          ),
          onCameraIdle: () async {
            if (_loading) {
              return;
            }
            _loading = true;
            // Finds the center of the map and load videos around that location
            final mapController = await controller.future;
            final bounds = await mapController.getVisibleRegion();
            await BlocProvider.of<VideosCubit>(context)
                .loadVideosWithinBoundingBox(bounds);
            _loading = false;
          },
          onMapCreated: (GoogleMapController mapController) {
            try {
              controller.complete(mapController);
              mapController.setMapStyle(
                  '[{"featureType":"all","elementType":"geometry","stylers":[{"color":"#202c3e"}]},{"featureType":"all","elementType":"labels.text","stylers":[{"visibility":"off"}]},{"featureType":"all","elementType":"labels.text.fill","stylers":[{"gamma":0.01},{"lightness":20},{"weight":"1.39"},{"color":"#ffffff"},{"visibility":"off"}]},{"featureType":"all","elementType":"labels.text.stroke","stylers":[{"weight":"0.96"},{"saturation":"9"},{"visibility":"off"},{"color":"#000000"}]},{"featureType":"all","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"geometry","stylers":[{"lightness":30},{"saturation":"9"},{"color":"#273556"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"saturation":20}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"lightness":20},{"saturation":-20}]},{"featureType":"road","elementType":"geometry","stylers":[{"lightness":10},{"saturation":-30}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#3f499d"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"saturation":25},{"lightness":25},{"weight":"0.01"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#ff0000"}]},{"featureType":"water","elementType":"all","stylers":[{"lightness":-20}]}]');
            } catch (e) {
              context.showErrorSnackbar('Error setting map style');
            }
          },
        ),
        Positioned(
          top: 10 + MediaQuery.of(context).padding.top,
          left: 36,
          right: 36 +
              (Theme.of(context).platform == TargetPlatform.android ? 36 : 0),
          child: _searchBar(context),
        ),
        if (widget._isLoading)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12, right: 12),
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

  Widget _searchBar(BuildContext context) {
    return GradientBorder(
      borderRadius: 50,
      strokeWidth: 1,
      gradient: redOrangeGradient,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF000000).withOpacity(
              _citySearchQueryController.text.isEmpty ? 0.15 : 0.5),
          borderRadius: const BorderRadius.all(Radius.circular(50)),
        ),
        child: Row(
          children: [
            const Icon(FeatherIcons.search),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _citySearchQueryController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Search by city',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onEditingComplete: () async {
                  final currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  final location =
                      await RepositoryProvider.of<Repository>(context)
                          .searchLocation(_citySearchQueryController.text);
                  if (location == null) {
                    context.showSnackbar('Could not find the location');
                    return;
                  }
                  final mapController = await controller.future;
                  await mapController
                      .moveCamera(CameraUpdate.newLatLng(location));
                },
              ),
            ),
            if (_citySearchQueryController.text.isNotEmpty)
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(_citySearchQueryController.clear);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant Map oldWidget) {
    _createMarkers(videos: widget._videos, context: context)
        .then((_) => _initiallyMoveCameraToShowAllMarkers());
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _citySearchQueryController.addListener(updateUI);
    super.initState();
  }

  @override
  void dispose() {
    _citySearchQueryController
      ..removeListener(updateUI)
      ..dispose();
    super.dispose();
  }

  void updateUI() {
    setState(() {});
  }

  Future<void> _initiallyMoveCameraToShowAllMarkers() async {
    if (_markers.isEmpty) {
      return;
    }
    if (_hasLoadedMarkers) {
      return;
    }
    _hasLoadedMarkers = true;
    final mapController = await controller.future;
    if (_markers.length == 1) {
      // If there is only 1 marker, move camera to centre that marker
      return mapController
          .moveCamera(CameraUpdate.newLatLng(_markers.first.position));
    }
    final cordinatesList =
        List<LatLng>.from(_markers.map((marker) => marker.position))
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
    return mapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 40));
  }

  Future<void> _createMarkers({
    required List<Video> videos,
    required BuildContext context,
  }) async {
    /// Only create markers for videos that the marker does not exist yet.
    final markerIds =
        _markers.toList().map((marker) => marker.markerId.value).toList();
    final newVideos = videos.where((video) => !markerIds.contains(video.id));

    if (videos.length < _markers.length) {
      /// Delete marker for videos that is not included in videos
      final videoIds = videos.map((video) => video.id).toList();

      setState(() {
        _markers
            .removeWhere((marker) => !videoIds.contains(marker.markerId.value));
      });
      return;
    }
    if (newVideos.isEmpty) {
      return;
    }
    final factor = _getMapFactor();
    final markerSize = _getMarkerSize(factor);

    final loadingMarkerImage =
        await _createLoadingMarkerImage(factor: factor, markerSize: markerSize);

    final loadingNewMarkers = newVideos.map((video) => Marker(
          anchor: const Offset(0.5, 0.5),
          markerId: MarkerId(video.id),
          position: video.location!,
          icon: loadingMarkerImage,
          zIndex: RepositoryProvider.of<Repository>(context)
              .getZIndex(video.createdAt),
        ));

    setState(() {
      _markers.addAll(loadingNewMarkers.toSet());
    });

    await Future.wait(
      newVideos.map<Future<void>>(
        (video) => _createMarkerFromVideo(
          video: video,
          context: context,
          factor: factor,
          markerSize: markerSize,
        ),
      ),
    );
  }

  /// Get factor of marker size depending on device's pixel ratio
  int _getMapFactor() {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    var factor = 1;
    if (devicePixelRatio >= 1.5) {
      factor = 2;
    } else if (devicePixelRatio >= 2.5) {
      factor = 3;
    } else if (devicePixelRatio >= 3.5) {
      factor = 4;
    }
    return factor;
  }

  /// Get markers' actual size
  double _getMarkerSize(int factor) => factor * markerSize;

  Future<BitmapDescriptor> _createLoadingMarkerImage({
    required int factor,
    required double markerSize,
  }) async {
    final imagePadding = borderWidth * factor;
    final imageSize = markerSize - imagePadding * 2;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final boundingRect = Rect.fromLTWH(0.0, 0.0, markerSize, markerSize);

    final paint = Paint()
      ..shader = redOrangeGradient.createShader(
        boundingRect,
      );

    final centerOffset = Offset(markerSize / 2, markerSize / 2);

    canvas
      ..drawCircle(centerOffset, markerSize / 2, paint)
      ..drawCircle(
          centerOffset, imageSize / 2, paint..blendMode = BlendMode.srcOut)
      ..restore();

    final span = const TextSpan(
        style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 36),
        text: 'Loading');
    final textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
        canvas,
        centerOffset.translate(
            -textPainter.width / 2, -textPainter.height / 2));

    final img = await pictureRecorder
        .endRecording()
        .toImage(markerSize.toInt(), markerSize.toInt());

    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw PlatformException(
        code: 'marker error',
        message: 'Error while creating byteData',
      );
    }
    final markerIcon = data.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<void> _createMarkerFromVideo({
    required Video video,
    required BuildContext context,
    required int factor,
    required double markerSize,
  }) async {
    var onTap = () {
      Navigator.of(context).push(
        ViewVideoPage.route(video.id),
      );
    };

    final imagePadding = borderWidth * factor;
    final imageSize = markerSize - imagePadding * 2;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final boundingRect = Rect.fromLTWH(0.0, 0.0, markerSize, markerSize);
    final centerOffset = Offset(markerSize / 2, markerSize / 2);

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
    final imageFile = await RepositoryProvider.of<Repository>(context)
        .getCachedFile(video.thumbnailUrl);

    final imageBytes = await imageFile.readAsBytes();
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
      throw PlatformException(
          code: 'byteData null', message: 'byteData is null');
    }
    final resizedMarkerImageBytes = byteData.buffer.asUint8List();
    final image =
        await _loadImage(Uint8List.view(resizedMarkerImageBytes.buffer));

    canvas
      ..drawCircle(centerOffset, markerSize / 2, paint)
      ..saveLayer(boundingRect, paint)
      ..drawCircle(centerOffset, imageSize / 2, paint)
      ..drawImage(image, Offset(imagePadding, imagePadding),
          paint..blendMode = BlendMode.srcIn)
      ..restore();

    final img = await pictureRecorder
        .endRecording()
        .toImage(markerSize.toInt(), markerSize.toInt());

    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw PlatformException(
        code: 'marker error',
        message: 'Error while creating byteData',
      );
    }
    final markerIcon = data.buffer.asUint8List();

    final marker = Marker(
      anchor: const Offset(0.5, 0.5),
      onTap: onTap,
      consumeTapEvents: true,
      markerId: MarkerId(video.id),
      position: video.location!,
      icon: BitmapDescriptor.fromBytes(markerIcon),
      zIndex:
          RepositoryProvider.of<Repository>(context).getZIndex(video.createdAt),
    );

    _markers.removeWhere(
        (targetMarker) => targetMarker.markerId == marker.markerId);
    setState(() {
      _markers.add(marker);
    });
  }

  Future<ui.Image> _loadImage(Uint8List img) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img, completer.complete);
    return completer.future;
  }
}
