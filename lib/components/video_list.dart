import 'package:flutter/material.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/utils/constants.dart';

/// Displays videos in a grid
class VideoGrid extends StatelessWidget {
  /// Displays videos in a grid
  const VideoGrid({
    Key? key,
    required List<Video> videos,
  })  : _videos = videos,
        super(key: key);

  final List<Video> _videos;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        alignment: WrapAlignment.start,
        children: List.generate(_videos.length, (index) {
          final video = _videos[index];
          return SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(ViewVideoPage.route(videoId: video.id));
                },
                child: Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return preloader;
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
