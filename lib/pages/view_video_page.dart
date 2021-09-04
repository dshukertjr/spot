import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/components/frosted_dialog.dart';
import 'package:spot/components/full_screen_video_player.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/comment/comment_cubit.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/profile_page.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/functions.dart';
import 'package:video_player/video_player.dart';

import '../utils/constants.dart';
import 'tab_page.dart';

@visibleForTesting
enum VideoMenu {
  block,
  report,
  delete,
}

class ViewVideoPage extends StatelessWidget {
  const ViewVideoPage({
    Key? key,
    required this.videoId,
    this.video,
  }) : super(key: key);

  static const name = 'ViewVideoPage';

  final String videoId;
  final Video? video;

  static Route<void> route({
    required String videoId,
    Video? video,
  }) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: name),
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<VideoCubit>(
            create: (context) => VideoCubit(
                repository: RepositoryProvider.of<Repository>(context))
              ..initialize(videoId),
          ),
          BlocProvider<CommentCubit>(
            create: (context) => CommentCubit(
              repository: RepositoryProvider.of<Repository>(context),
              videoId: videoId,
            ),
          ),
        ],
        child: ViewVideoPage(videoId: videoId, video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          if (state is VideoInitial) {
            if (video != null) {
              return Hero(
                tag: video!.id,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      video!.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return preloader;
          } else if (state is VideoLoading) {
            final video = state.videoDetail;
            return VideoScreen(
              video: video,
            );
          } else if (state is VideoPlaying) {
            return VideoScreen(
              controller: state.videoPlayerController,
              video: state.videoDetail,
            );
          } else if (state is VideoError) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Center(child: Text(state.message)),
                Positioned(
                  top: 18 + MediaQuery.of(context).padding.top,
                  left: 18,
                  child: BackButton(
                    onPressed: Navigator.of(context).pop,
                  ),
                ),
              ],
            );
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

@visibleForTesting
class VideoScreen extends StatefulWidget {
  const VideoScreen({
    Key? key,
    VideoPlayerController? controller,
    required VideoDetail video,
  })  : _controller = controller,
        _video = video,
        super(key: key);

  final VideoPlayerController? _controller;
  final VideoDetail _video;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final String? _userId;
  bool _isCommentsShown = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget._controller == null
            ? preloader
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
          child: _rightButtons(context),
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
                if (widget._video.locationString != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FeatherIcons.mapPin, size: 18),
                      const SizedBox(width: 4),
                      Expanded(child: Text(widget._video.locationString!)),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
        if (_isCommentsShown)
          Positioned.fill(
            child: WillPopScope(
              onWillPop: () async {
                await widget._controller?.play();
                setState(() {
                  _isCommentsShown = false;
                });
                return false;
              },
              child: CommentsOverlay(
                onClose: () async {
                  await widget._controller?.play();
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

  Widget _rightButtons(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        width: 36,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileImage(
              imageUrl: widget._video.createdBy.imageUrl,
              onPressed: () async {
                await widget._controller?.pause();
                await Navigator.of(context)
                    .push(ProfilePage.route(widget._video.createdBy.id));
                await widget._controller?.play();
              },
              size: 36,
            ),
            const SizedBox(height: 36),
            IconButton(
              icon: const Icon(FeatherIcons.messageCircle),
              onPressed: () async {
                setState(() {
                  _isCommentsShown = true;
                });
                await widget._controller?.pause();
                await BlocProvider.of<CommentCubit>(context).loadComments();
              },
            ),
            Text(widget._video.commentCount.toString()),
            const SizedBox(height: 36),
            IconButton(
              icon: widget._video.haveLiked
                  ? const Icon(
                      Icons.favorite,
                      color: appOrange,
                    )
                  : const Icon(
                      Icons.favorite_border,
                      color: Color(0xFFFFFFFF),
                    ),
              onPressed: () {
                AuthRequired.action(context, action: () {
                  if (widget._video.haveLiked) {
                    BlocProvider.of<VideoCubit>(context).unlike();
                  } else {
                    BlocProvider.of<VideoCubit>(context).like();
                  }
                });
              },
            ),
            Text(widget._video.likeCount.toString()),
            const SizedBox(height: 36),
            IconButton(
              onPressed: () {
                BlocProvider.of<VideoCubit>(context).shareVideo();
              },
              icon: const Icon(FeatherIcons.share2),
            ),
            const SizedBox(height: 36),
            PopupMenuButton<VideoMenu>(
              onSelected: (VideoMenu result) {
                AuthRequired.action(context, action: () async {
                  switch (result) {
                    case VideoMenu.block:
                      _showBlockDialog();
                      break;
                    case VideoMenu.report:
                      final reported = await _showReportDialog();
                      if (reported == true) {
                        context.showSnackbar('Thanks for reporting');
                      }
                      break;
                    case VideoMenu.delete:
                      _showDeleteDialog();
                      break;
                  }
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<VideoMenu>>[
                const PopupMenuItem<VideoMenu>(
                  value: VideoMenu.block,
                  child: Text('Block this user'),
                ),
                const PopupMenuItem<VideoMenu>(
                  value: VideoMenu.report,
                  child: Text('Report this video'),
                ),
                if (widget._video.userId == _userId)
                  const PopupMenuItem<VideoMenu>(
                    value: VideoMenu.delete,
                    child: Text('Delete this video'),
                  ),
              ],
              child: const Icon(FeatherIcons.moreHorizontal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _userId = RepositoryProvider.of<Repository>(context).userId;
    super.initState();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return FrostedDialog(
            child: _DeletingDialogContent(
          videoCubit: BlocProvider.of<VideoCubit>(context),
        ));
      },
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

class _DeletingDialogContent extends StatefulWidget {
  _DeletingDialogContent({
    Key? key,
    required VideoCubit videoCubit,
  })  : _videoCubit = videoCubit,
        super(key: key);

  final VideoCubit _videoCubit;

  @override
  __DeletingDialogContentState createState() => __DeletingDialogContentState();
}

class __DeletingDialogContentState extends State<_DeletingDialogContent> {
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
              const Text('Are you sure you want to delete this video?'),
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
                        await widget._videoCubit.delete();
                        Navigator.of(context).popUntil(
                          (route) => route.settings.name == TabPage.name,
                        );
                      } catch (err) {
                        setState(() {
                          _loading = false;
                        });
                        context.showErrorSnackbar(
                            'Error occured while blocking the user.');
                      }
                    },
                    child: const Text('Delete Video'),
                  ),
                ],
              ),
            ],
          );
  }
}

class _BlockingDialogContent extends StatefulWidget {
  _BlockingDialogContent({
    Key? key,
    required VideoCubit videoCubit,
    required String blockedUserId,
  })  : _videoCubit = videoCubit,
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
                        context.showErrorSnackbar(
                            'Error occured while blocking the user.');
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
  })  : _videoCubit = videoCubit,
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
                maxLines: null,
                controller: _reasonController,
                textCapitalization: TextCapitalization.sentences,
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
                        context.showErrorSnackbar(
                            'Error occured while reporting the video');
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

@visibleForTesting
class CommentsOverlay extends StatefulWidget {
  CommentsOverlay({
    Key? key,
    required void Function() onClose,
  })  : _onClose = onClose,
        super(key: key);

  final void Function() _onClose;

  @override
  _CommentsOverlayState createState() => _CommentsOverlayState();
}

class _CommentsOverlayState extends State<CommentsOverlay> {
  late final TextEditingController _commentController;

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
              child: BlocBuilder<CommentCubit, CommentState>(
                builder: (context, state) {
                  if (state is CommentInitial) {
                    return preloader;
                  } else if (state is CommentsEmpty) {
                    return const Center(
                      child: Text('There are no comments yet'),
                    );
                  } else if (state is CommentsLoaded) {
                    final comments = state.comments;
                    final mentionSuggestions = state.mentionSuggestions;
                    final isLoadingMentions = state.isLoadingMentions;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        _commentsList(comments: comments),
                        Positioned.fill(
                          top: null,
                          child: _mentionSuggestionList(
                            mentionSuggestions: mentionSuggestions,
                            isLoadingMentions: isLoadingMentions,
                          ),
                        ),
                      ],
                    );
                  } else if (state is CommentError) {
                    return const Center(child: Text('Error loading comments'));
                  }
                  throw UnimplementedError(
                      'Unknown state ${state.toString()} at CommentsOverlay');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLines: 4,
                      minLines: 1,
                      controller: _commentController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF999999),
                          ),
                        ),
                        hintText: 'What did you think about the video?',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GradientButton(
                    onPressed: () {
                      AuthRequired.action(context, action: () {
                        BlocProvider.of<CommentCubit>(context)
                            .postComment(_commentController.text);
                        _commentController.clear();
                      });
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

  @override
  void initState() {
    _commentController = TextEditingController()..addListener(_getMentions);
    super.initState();
  }

  @override
  void dispose() {
    _commentController
      ..removeListener(_getMentions)
      ..dispose();
    super.dispose();
  }

  Widget _mentionSuggestionList({
    required List<Profile>? mentionSuggestions,
    required bool isLoadingMentions,
  }) {
    if (isLoadingMentions) {
      return const SizedBox(
        height: 120,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x99000000),
          ),
          child: preloader,
        ),
      );
    } else if (mentionSuggestions != null) {
      if (mentionSuggestions.isEmpty) {
        return const SizedBox(
          height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x99000000),
            ),
            child: Center(
              child: Text('No matching user found'),
            ),
          ),
        );
      } else {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0x99000000),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: mentionSuggestions
                  .map<Widget>(
                    (profile) => ListTile(
                      leading: ProfileImage(imageUrl: profile.imageUrl),
                      title: Text(profile.name),
                      onTap: () {
                        final commentText = _commentController.text;
                        final replacedComment =
                            BlocProvider.of<CommentCubit>(context)
                                .createCommentWithMentionedProfile(
                          commentText: commentText,
                          profileName: profile.name,
                        );
                        setState(() {
                          _commentController
                            ..text = replacedComment
                            ..selection = TextSelection.fromPosition(
                                TextPosition(
                                    offset: _commentController.text.length));
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      }
    }
    return Container();
  }

  Widget _commentsList({required List<Comment> comments}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      itemCount: comments.length,
      itemBuilder: (_, index) {
        final comment = comments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              ProfileImage(
                imageUrl: comment.user.imageUrl,
                onPressed: () {
                  Navigator.of(context)
                      .push(ProfilePage.route(comment.user.id));
                },
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

  /// Get mentioned userID everytime comment is updated
  Future<void> _getMentions() {
    return BlocProvider.of<CommentCubit>(context)
        .getMentionSuggestion(_commentController.text);
  }
}
