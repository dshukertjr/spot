import 'package:flutter/material.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/view_video_page.dart';

class VideoList extends StatelessWidget {
  const VideoList({
    Key? key,
    required this.videos,
  }) : super(key: key);

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        alignment: WrapAlignment.start,
        children: List.generate(videos.length, (index) {
          final video = videos[index];
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
