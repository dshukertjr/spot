import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/full_screen_video_player.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/video.dart';
import 'package:video_player/video_player.dart';

import '../components/app_scaffold.dart';

class ViewVideoPage extends StatelessWidget {
  static Route<void> route(String videoId) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => VideoCubit()..initialize(videoId),
        child: ViewVideoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          if (state is VideoInitial) {
            return preloader;
          } else if (state is VideoLoading) {
            final video = state.video;
            return _VideoScreen(
              video: video,
            );
          } else if (state is VideoPlaying) {
            final controller = state.videoPlayerController;
            final video = state.video;
            return _VideoScreen(
              controller: controller,
              video: video,
            );
          } else if (state is VideoPaused) {
            final controller = state.videoPlayerController;
            final video = state.video;
            return _VideoScreen(
              controller: controller,
              video: video,
            );
          }
          return Container();
        },
      ),
    );
  }
}

class _VideoScreen extends StatefulWidget {
  const _VideoScreen({
    Key? key,
    this.controller,
    required this.video,
  }) : super(key: key);

  final VideoPlayerController? controller;
  final Video video;

  @override
  __VideoScreenState createState() => __VideoScreenState();
}

class __VideoScreenState extends State<_VideoScreen> {
  bool _isCommentsShown = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.controller == null
            ? Image.network(
                widget.video.thumbnailUrl,
                fit: BoxFit.cover,
              )
            : FullScreenVideoPlayer(
                videoPlayerController: widget.controller!,
              ),
        Positioned(
          left: 18,
          top: MediaQuery.of(context).padding.top + 18,
          child: const BackButton(),
        ),
        Positioned(
          bottom: 123,
          right: 14,
          child: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 36,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.network(
                      'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 36),
                  IconButton(
                    icon: const Icon(FeatherIcons.messageCircle),
                    onPressed: () async {
                      await BlocProvider.of<VideoCubit>(context).pause();
                      setState(() {
                        _isCommentsShown = true;
                      });
                    },
                  ),
                  const SizedBox(height: 36),
                  IconButton(
                    icon: const Icon(FeatherIcons.heart),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 36),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 19,
          bottom: 50,
          child: SizedBox(
            width: 195,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@${widget.video.createdBy.name}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.video.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isCommentsShown)
          Positioned.fill(
            child: WillPopScope(
              onWillPop: () async {
                await BlocProvider.of<VideoCubit>(context).resume();
                setState(() {
                  _isCommentsShown = false;
                });
                return false;
              },
              child: _CommentsOverlay(
                onClose: () {
                  setState(() {
                    _isCommentsShown = false;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _CommentsOverlay extends StatefulWidget {
  _CommentsOverlay({
    Key? key,
    required void Function() onClose,
  })   : _onClose = onClose,
        super(key: key);

  final void Function() _onClose;

  @override
  __CommentsOverlayState createState() => __CommentsOverlayState();
}

class __CommentsOverlayState extends State<_CommentsOverlay> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: buttonBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + 16,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () {
                  widget._onClose();
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                itemCount: 20,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        ProfileImage(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('@TrueNewyorker'),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text:
                                            'I would love to visit New York someday. I hope covid ends soon so that I can visit there.'),
                                    TextSpan(
                                      text: ' 1h',
                                      style: TextStyle(
                                        color: Color(0x88ffffff),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'What did you think about the video?',
                      ),
                    ),
                  ),
                  GradientButton(
                    onPressed: () {},
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
