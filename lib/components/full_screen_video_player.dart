import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatelessWidget {
  const FullScreenVideoPlayer({
    Key? key,
    required VideoPlayerController videoPlayerController,
  })   : _videoPlayerController = videoPlayerController,
        super(key: key);

  final VideoPlayerController _videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Toggle video play
        if (_videoPlayerController.value.isPlaying) {
          _videoPlayerController.pause();
        } else {
          _videoPlayerController.play();
        }
      },
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              height: 1,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
