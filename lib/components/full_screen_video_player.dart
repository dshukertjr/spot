import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

/// Video play that takes up the full screen
class FullScreenVideoPlayer extends StatefulWidget {
  /// Video play that takes up the full screen
  const FullScreenVideoPlayer({
    Key? key,
    required BetterPlayerController videoPlayerController,
  })  : _videoPlayerController = videoPlayerController,
        super(key: key);

  final BetterPlayerController _videoPlayerController;

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Toggle video play
        if (widget._videoPlayerController.isPlaying()!) {
          await widget._videoPlayerController.pause();
        } else {
          await widget._videoPlayerController.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          BetterPlayer(
            controller: widget._videoPlayerController,
          ),
          if (!widget._videoPlayerController.isPlaying()!)
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
    // widget._videoPlayerController.addListener(updateUi);
    widget._videoPlayerController.addEventsListener(_updateUi);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    widget._videoPlayerController
        .setOverriddenAspectRatio(MediaQuery.of(context).size.aspectRatio);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget._videoPlayerController.removeEventsListener(_updateUi);
    super.dispose();
  }

  void _updateUi(_) {
    setState(() {});
  }
}
