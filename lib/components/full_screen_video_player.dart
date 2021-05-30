import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  const FullScreenVideoPlayer({
    Key? key,
    required VideoPlayerController videoPlayerController,
  })  : _videoPlayerController = videoPlayerController,
        super(key: key);

  final VideoPlayerController _videoPlayerController;

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Toggle video play
        if (widget._videoPlayerController.value.isPlaying) {
          await widget._videoPlayerController.pause();
        } else {
          if (isVideoAtEnd) {
            await widget._videoPlayerController.seekTo(Duration.zero);
          }
          await widget._videoPlayerController.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  height: 1,
                  child: AspectRatio(
                    aspectRatio: widget._videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(widget._videoPlayerController),
                  ),
                ),
              ),
            ),
          ),
          if (!widget._videoPlayerController.value.isPlaying)
            Center(
              child: Material(
                borderRadius: BorderRadius.circular(100),
                color: const Color(0xFF000000).withOpacity(0.25),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.play_arrow,
                    size: 56,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    widget._videoPlayerController.addListener(updateUi);
    super.initState();
  }

  @override
  void dispose() {
    widget._videoPlayerController.removeListener(updateUi);
    super.dispose();
  }

  void updateUi() {
    setState(() {});
  }

  bool get isVideoAtEnd =>
      widget._videoPlayerController.value.duration == widget._videoPlayerController.value.position;
}
