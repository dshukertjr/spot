import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/frosted_dialog.dart';
import 'package:spot/components/full_screen_video_player.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/components/profile_image.dart';
import 'package:spot/cubits/video/video_cubit.dart';
import 'package:spot/models/comment.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/models/video.dart';
import 'package:spot/pages/profile_page.dart';
import 'package:spot/repositories/repository.dart';
import 'package:video_player/video_player.dart';

import '../app/constants.dart';
import '../components/app_scaffold.dart';
import 'tab_page.dart';

@visibleForTesting
enum VideoMenu {
  block,
  report,
  delete,
}

class ViewVideoPage extends StatelessWidget {
  static Route<void> route(String videoId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<VideoCubit>(
        create: (context) =>
            VideoCubit(repository: RepositoryProvider.of<Repository>(context))..initialize(videoId),
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
            final video = state.videoDetail;
            return VideoScreen(
              video: video,
            );
          } else if (state is VideoPlaying) {
            return VideoScreen(
              controller: state.videoPlayerController,
              video: state.videoDetail,
              isCommentsShown: state.isCommentsShown,
              comments: state.comments,
              mentionSuggestions: state.mentionSuggestions,
              isMentionnsLoading: state.isLoadingMentions,
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
    bool? isCommentsShown,
    List<Comment>? comments,
    List<Profile>? mentionSuggestions,
    bool isMentionnsLoading = false,
  })  : _controller = controller,
        _video = video,
        _isCommentsShown = isCommentsShown ?? false,
        _comments = comments,
        _mentionSuggestions = mentionSuggestions,
        _isLoadingMentions = isMentionnsLoading,
        super(key: key);

  final VideoPlayerController? _controller;
  final VideoDetail _video;
  final bool _isCommentsShown;
  final List<Comment>? _comments;
  final List<Profile>? _mentionSuggestions;
  final bool _isLoadingMentions;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final String _userId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget._controller == null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget._video.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  const Center(child: preloader),
                ],
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
                      await widget._controller?.pause();
                      await BlocProvider.of<VideoCubit>(context).showComments();
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
                    onPressed: () {
                      BlocProvider.of<VideoCubit>(context).shareVideo();
                    },
                    icon: const Icon(FeatherIcons.share2),
                  ),
                  const SizedBox(height: 36),
                  PopupMenuButton<VideoMenu>(
                    onSelected: (VideoMenu result) async {
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
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<VideoMenu>>[
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
                await widget._controller?.play();
                await BlocProvider.of<VideoCubit>(context).hideComments();
                return false;
              },
              child: CommentsOverlay(
                onClose: () async {
                  await widget._controller?.play();
                  await BlocProvider.of<VideoCubit>(context).hideComments();
                },
                comments: widget._comments,
                mentionSuggestions: widget._mentionSuggestions,
                isLoadingMentions: widget._isLoadingMentions,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    final userId = RepositoryProvider.of<Repository>(context).userId;
    if (userId == null) {
      throw PlatformException(code: 'not signed in');
    }
    _userId = userId;
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
                        context.showErrorSnackbar('Error occured while blocking the user.');
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
                        context.showErrorSnackbar('Error occured while blocking the user.');
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
  __ReportingDialogContentState createState() => __ReportingDialogContentState();
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
              const Text('Could you please tell us why you would like to report this video?'),
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
                        context.showErrorSnackbar('Error occured while reporting the video');
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
    required List<Comment>? comments,
    required List<Profile>? mentionSuggestions,
    required bool isLoadingMentions,
  })  : _onClose = onClose,
        _comments = comments,
        _mentionSuggestions = mentionSuggestions,
        _isLoadingMentions = isLoadingMentions,
        super(key: key);

  final void Function() _onClose;
  final List<Comment>? _comments;
  final List<Profile>? _mentionSuggestions;
  final bool _isLoadingMentions;

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
              child: _commentsList(),
            ),
            SizedBox(
              height: 0,
              child: OverflowBox(
                maxHeight: 112,
                alignment: Alignment.bottomCenter,
                child: _suggestionList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      BlocProvider.of<VideoCubit>(context).comment(_commentController.text);
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

  Widget _suggestionList() {
    final mentionSuggestions = widget._mentionSuggestions;
    if (widget._isLoadingMentions) {
      return const SizedBox(
        height: 120,
        child: preloader,
      );
    } else if (mentionSuggestions != null) {
      if (mentionSuggestions.isEmpty) {
        return const SizedBox(
          height: 120,
          child: Center(
            child: Text('No matching user found'),
          ),
        );
      } else {
        return SizedBox(
          height: 56.0 * min(mentionSuggestions.length, 2) + 8,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Color(0x33000000)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: mentionSuggestions
                  .map<Widget>(
                    (mentionnSuggestion) => ListTile(
                      leading: ProfileImage(imageUrl: mentionnSuggestion.imageUrl),
                      title: Text(mentionnSuggestion.name),
                      onTap: () {},
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
                imageUrl: comment.user.imageUrl,
                onPressed: () {
                  Navigator.of(context).push(ProfilePage.route(comment.user.id));
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

  Future<void> _getMentions() {
    return BlocProvider.of<VideoCubit>(context).getMentionSuggestion(_commentController.text);
  }
}
