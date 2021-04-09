import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/full_screen_video_player.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/video.dart';
import 'package:spot/repositories/repository.dart';
import 'package:video_player/video_player.dart';

import '../components/app_scaffold.dart';

class ViewVideoPage extends StatelessWidget {
  static Route<void> route(String videoId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) =>
            VideoCubit(repository: RepositoryProvider.of<Repository>(context))
              ..initialize(videoId),
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
            return _VideoScreen(
              controller: state.videoPlayerController,
              video: state.video,
              isCommentsShown: state.isCommentsShown,
              comments: state.comments,
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
    VideoPlayerController? controller,
    required VideoDetail video,
    bool? isCommentsShown,
    List<Comment>? comments,
  })  : _controller = controller,
        _video = video,
        _isCommentsShown = isCommentsShown ?? false,
        _comments = comments,
        super(key: key);

  final VideoPlayerController? _controller;
  final VideoDetail _video;
  final bool _isCommentsShown;
  final List<Comment>? _comments;

  @override
  __VideoScreenState createState() => __VideoScreenState();
}

class __VideoScreenState extends State<_VideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget._controller == null
            ? Image.network(
                widget._video.imageUrl,
                fit: BoxFit.cover,
              )
            : FullScreenVideoPlayer(
                videoPlayerController: widget._controller!,
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
                      await widget._controller!.pause();
                      await BlocProvider.of<VideoCubit>(context).showComments();
                    },
                  ),
                  Text(widget._video.commentCount.toString()),
                  const SizedBox(height: 36),
                  IconButton(
                    icon: const Icon(FeatherIcons.heart),
                    onPressed: () {
                      if (widget._video.haveLiked) {
                        BlocProvider.of<VideoCubit>(context).unlike();
                      } else {
                        BlocProvider.of<VideoCubit>(context).like();
                      }
                    },
                  ),
                  Text(widget._video.likeCount.toString()),
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
                  '@${widget._video.createdBy.name}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget._video.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget._isCommentsShown)
          Positioned.fill(
            child: WillPopScope(
              onWillPop: () async {
                await widget._controller!.play();
                BlocProvider.of<VideoCubit>(context).hideComments();
                return false;
              },
              child: _CommentsOverlay(
                comments: widget._comments,
                onClose: () async {
                  await widget._controller!.play();
                  BlocProvider.of<VideoCubit>(context).hideComments();
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
    required List<Comment>? comments,
  })   : _onClose = onClose,
        _comments = comments,
        super(key: key);

  final void Function() _onClose;
  final List<Comment>? _comments;

  @override
  __CommentsOverlayState createState() => __CommentsOverlayState();
}

class __CommentsOverlayState extends State<_CommentsOverlay> {
  final _commentController = TextEditingController();

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
              child: _commentsList(),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'What did you think about the video?',
                      ),
                    ),
                  ),
                  GradientButton(
                    onPressed: () {
                      BlocProvider.of<VideoCubit>(context)
                          .comment(_commentController.text);
                      _commentController.clear();
                    },
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

  Widget _commentsList() {
    if (widget._comments == null) {
      return preloader;
    } else if (widget._comments!.isEmpty) {
      return const Center(child: Text('There are no comments yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      itemCount: widget._comments!.length,
      itemBuilder: (_, index) {
        final comment = widget._comments![index];
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
                    Text('${comment.user.name}'),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: comment.text),
                          TextSpan(
                            text: ' ${howLongAgo(comment.createdAt)}',
                            style: const TextStyle(
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
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
