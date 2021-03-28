import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/cubits/videos/videos_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';

class MapTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
      builder: (context, state) {
        if (state is VideosInitial) {
          return _Map();
        } else if (state is VideosLoaded) {
          return _Map();
        }
        return _Map();
      },
    );
  }

  Future<Set<Marker>> _createMarkers({
    required List<Video> videos,
    required BuildContext context,
  }) async {
    final markers = await Future.wait(videos
        .map<Future<Marker>>((video) =>
            _createMarkerImageFromAsset(video: video, context: context))
        .toList());
    return markers.toSet();
  }

  Future<Marker> _createMarkerImageFromAsset({
    required Video video,
    required BuildContext context,
  }) async {
    const videoLifeSpan = Duration(days: 7);
    const markerSize = 70.0;
    const lifeTimeIndicatorWidth = 5.0;

    var onTap = () {
      Navigator.of(context, rootNavigator: true).push(
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
    final remainingPercent = (1 -
            (DateTime.now().difference(video.createdAt)).inMilliseconds /
                videoLifeSpan.inMilliseconds)
        .clamp(0.0, 1.0);

    // hue of 120 is green and has the most time left
    // hue of 0 is red and has no time left
    final indicatorColor = HSLColor.fromAHSL(1, remainingPercent * 120, 1, 0.4);

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = indicatorColor.toColor();

    final boundingRect = Rect.fromLTWH(0.0, 0.0, size, size);

    // start adding images
    final res = await http.get(Uri.parse(video.thumbnailUrl));
    final imageBytes = res.bodyBytes;
    final imageCodec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: imageSize.toInt(),
    );
    final frameInfo = await imageCodec.getNextFrame();
    final byteData = (await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!;
    final resizedMarkerImageBytes = byteData.buffer.asUint8List();
    final image =
        await loadImage(Uint8List.view(resizedMarkerImageBytes.buffer));

    //start adding duration indicator
    canvas
      ..drawArc(boundingRect, -pi / 2 + (2 * pi * (1 - remainingPercent)),
          2 * pi * remainingPercent, true, paint)
      ..saveLayer(boundingRect, paint)
      ..drawCircle(Offset(size / 2, size / 2), imageSize / 2, paint)
      ..drawImage(image, Offset(imagePadding, imagePadding),
          paint..blendMode = BlendMode.srcIn);

    final distance = await video.getDistanceInMeter();
    if (distance > 1000) {
      final lockPaint = Paint()..color = Colors.white.withOpacity(0.3);
      canvas.drawCircle(Offset(size / 2, size / 2), imageSize / 2, lockPaint);
      final iconData = Icons.lock_outline;
      var textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )
        ..text = TextSpan(
          text: String.fromCharCode(iconData.codePoint),
          style: TextStyle(
            fontSize: imageSize * 0.8,
            fontFamily: iconData.fontFamily,
            color: Colors.white.withOpacity(0.4),
          ),
        )
        ..layout(
          maxWidth: imageSize,
          minWidth: imageSize,
        )
        ..paint(canvas, Offset(imagePadding, imagePadding + imageSize * 0.1));

      onTap = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Get within 1km of the video to view it'),
          ),
        );
      };
    }

    canvas.restore();

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
      position: const LatLng(0, 0),
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img, completer.complete);
    return completer.future;
  }
}

class _Map extends StatelessWidget {
  _Map({
    Key? key,
    Set<Marker>? markers,
  })  : _markers = markers ?? <Marker>{},
        super(key: key);

  final Set<Marker> _markers;

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: _markers,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      initialCameraPosition: const CameraPosition(
        target: LatLng(37.43296265331129, -122.08832357078792),
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
}
