import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot/pages/view_video_page.dart';

import '../models/profile.dart';
import '../models/video.dart';
import 'profile_image.dart';

class UserProfile extends StatelessWidget {
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
      videoImageUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      thumbnailUrl:
          'https://tblg.k-img.com/restaurant/images/Rvw/91056/640x640_rect_91056529.jpg',
      gifUrl:
          'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
      position: const LatLng(37.43296265331129, -122.08832357078792),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 31,
              horizontal: 19,
            ),
            child: Row(
              children: [
                const ProfileImage(size: 120),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('@Newyorker'),
                      const SizedBox(height: 17),
                      const Text('I enjoy using this app. '),
                    ],
                  ),
                ),
              ],
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
