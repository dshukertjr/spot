import 'package:flutter/material.dart';
import 'package:spot/models/video.dart';

import '../../models/profile.dart';
import '../view_video_page.dart';

class SearchTab extends StatelessWidget {
  final videos = [
    Video(
      id: '',
      createdAt: DateTime.now(),
      createdBy: Profile(
        id: '',
        name: 'aaa',
        imageUrl:
            'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      ),
      description: '',
      thumbnailUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      videoImageUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 30,
            ),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Search away my friend',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: Wrap(
              children: List.generate(videos.length, (index) {
                final video = videos[index];
                return FractionallySizedBox(
                  widthFactor: 0.5,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Ink(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(video.thumbnailUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(ViewVideoPage.route(video.id));
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
