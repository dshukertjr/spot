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

class MapTab extends StatelessWidget {
  static Widget create() {
    return BlocProvider<VideosCubit>(
      create: (context) => VideosCubit(
        databaseRepository: RepositoryProvider.of<Repository>(context),
      )..initialize(),
      child: MapTab(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
      builder: (context, state) {
        if (state is VideosInitial) {
          return preloader;
        } else if (state is VideosLoading) {
          return _Map(location: state.location);
        } else if (state is VideosLoaded) {
          return _Map(videos: state.videos);
        }
        return _Map();
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
  __MapState createState() => __MapState();
}

class __MapState extends State<_Map> {
  final Completer<GoogleMapController> _controller = Completer();

  var _markers = <Marker>{};

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
        tilt: 59.440717697143555,
        zoom: 16,
      ),
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle(
            '[{"featureType":"all","elementType":"geometry","stylers":[{"color":"#202c3e"}]},{"featureType":"all","elementType":"labels.text","stylers":[{"visibility":"off"}]},{"featureType":"all","elementType":"labels.text.fill","stylers":[{"gamma":0.01},{"lightness":20},{"weight":"1.39"},{"color":"#ffffff"},{"visibility":"off"}]},{"featureType":"all","elementType":"labels.text.stroke","stylers":[{"weight":"0.96"},{"saturation":"9"},{"visibility":"off"},{"color":"#000000"}]},{"featureType":"all","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"geometry","stylers":[{"lightness":30},{"saturation":"9"},{"color":"#273556"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"saturation":20}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"lightness":20},{"saturation":-20}]},{"featureType":"road","elementType":"geometry","stylers":[{"lightness":10},{"saturation":-30}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#3f499d"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"saturation":25},{"lightness":25},{"weight":"0.01"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#ff0000"}]},{"featureType":"water","elementType":"all","stylers":[{"lightness":-20}]}]');
        _controller.complete(controller);
      },
    );
  }

  @override
  void didUpdateWidget(covariant _Map oldWidget) {
    if (widget._videos.isNotEmpty &&
        widget._videos.length != oldWidget._videos.length) {
      _createMarkers(videos: widget._videos, context: context);
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _createMarkers({
    required List<Video> videos,
    required BuildContext context,
  }) async {
    final markers = await Future.wait(
      videos.map<Future<Marker>>(
        (video) => _createMarkerImageFromAsset(video: video, context: context),
      ),
    );
    setState(() {
      _markers = markers.toSet();
    });
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
      throw PlatformException(
          code: 'byteData null', message: 'byteData is null');
    }
    final resizedMarkerImageBytes = byteData.buffer.asUint8List();
    final image =
        await _loadImage(Uint8List.view(resizedMarkerImageBytes.buffer));

    //start adding duration indicator
    canvas
      ..drawCircle(Offset(size / 2, size / 2), size / 2, paint)
      ..saveLayer(boundingRect, paint)
      ..drawCircle(Offset(size / 2, size / 2), imageSize / 2, paint)
      ..drawImage(image, Offset(imagePadding, imagePadding),
          paint..blendMode = BlendMode.srcIn)
      ..restore();

    final img = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());

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
      position: video.location,
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );
  }

  Future<ui.Image> _loadImage(Uint8List img) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img, completer.complete);
    return completer.future;
  }
}
