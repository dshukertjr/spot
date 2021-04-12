import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/frosted_dialog.dart';
import 'package:spot/components/full_screen_video_player.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/video.dart';
import 'package:spot/repositories/repository.dart';
import 'package:video_player/video_player.dart';

import '../components/app_scaffold.dart';
import 'tab_page.dart';

enum _VideoMenu {
  block,
  report,
}

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
                  ProfileImage(
                    userId: widget._video.userId,
                    imageUrl: widget._video.createdBy.imageUrl,
                    openProfileOnTap: true,
                    size: 36,
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
                  PopupMenuButton<_VideoMenu>(
                    onSelected: (_VideoMenu result) async {
                      switch (result) {
                        case _VideoMenu.block:
                          _showBlockDialog();
                          break;
                        case _VideoMenu.report:
                          final reported = await _showReportDialog();
                          if (reported == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Thanks for reporting')),
                            );
                          }
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<_VideoMenu>>[
                      const PopupMenuItem<_VideoMenu>(
                        value: _VideoMenu.block,
                        child: Text('Block this user'),
                      ),
                      const PopupMenuItem<_VideoMenu>(
                        value: _VideoMenu.report,
                        child: Text('Report this video'),
                      ),
                    ],
                    child: const Icon(FeatherIcons.moreHorizontal),
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

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return FrostedDialog(
            child: _BlockingDialogContent(
          videoCubit: BlocProvider.of<VideoCubit>(context),
          blockedUserId: widget._video.userId,
        ));
      },
    );
  }

  Future<bool?> _showReportDialog() {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return FrostedDialog(
            child: _ReportingDialogContent(
          videoCubit: BlocProvider.of<VideoCubit>(context),
          videoId: widget._video.id,
        ));
      },
    );
  }
}

class _BlockingDialogContent extends StatefulWidget {
  _BlockingDialogContent({
    Key? key,
    required VideoCubit videoCubit,
    required String blockedUserId,
  })   : _videoCubit = videoCubit,
        _blockedUserId = blockedUserId,
        super(key: key);

  final VideoCubit _videoCubit;
  final String _blockedUserId;

  @override
  __BlockingDialogContentState createState() => __BlockingDialogContentState();
}

class __BlockingDialogContentState extends State<_BlockingDialogContent> {
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const SizedBox(
            height: 80,
            child: preloader,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to block this user?'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GradientButton(
                    strokeWidth: 0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          _loading = true;
                        });
                        await widget._videoCubit.block(widget._blockedUserId);
                        Navigator.of(context).popUntil(
                          (route) => route.settings.name == TabPage.name,
                        );
                      } catch (err) {
                        setState(() {
                          _loading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Error occured while blocking the user.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Block User'),
                  ),
                ],
              ),
            ],
          );
  }
}

class _ReportingDialogContent extends StatefulWidget {
  _ReportingDialogContent({
    Key? key,
    required VideoCubit videoCubit,
    required String videoId,
  })   : _videoCubit = videoCubit,
        _videoId = videoId,
        super(key: key);

  final VideoCubit _videoCubit;
  final String _videoId;

  @override
  __ReportingDialogContentState createState() =>
      __ReportingDialogContentState();
}

class __ReportingDialogContentState extends State<_ReportingDialogContent> {
  var _loading = false;
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const SizedBox(
            height: 80,
            child: preloader,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Could you please tell us why you would like to report this video?'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Report Reason',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GradientButton(
                    strokeWidth: 0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          _loading = true;
                        });
                        final reason = _reasonController.text;
                        await widget._videoCubit.report(
                          reason: reason,
                          videoId: widget._videoId,
                        );
                        Navigator.of(context).pop(true);
                      } catch (err) {
                        setState(() {
                          _loading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Error occured while blocking the user.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Report'),
                  ),
                ],
              ),
            ],
          );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
              ProfileImage(
                userId: comment.user.id,
                imageUrl: comment.user.imageUrl,
                openProfileOnTap: true,
              ),
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
