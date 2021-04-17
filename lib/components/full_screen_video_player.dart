import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class FullScreenVideoPlayer extends StatelessWidget {
  const FullScreenVideoPlayer({
    Key? key,
    required CachedVideoPlayerController videoPlayerController,
  })   : _videoPlayerController = videoPlayerController,
        super(key: key);

  final CachedVideoPlayerController _videoPlayerController;

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
                child: CachedVideoPlayer(_videoPlayerController),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
