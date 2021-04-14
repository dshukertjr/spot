import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/frosted_dialog.dart';
import 'package:spot/components/full_screen_video_player.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/cubits/confirm_video/confirm_video_cubit.dart';
import 'package:spot/pages/record_page.dart';
import 'package:spot/pages/tab_page.dart';
import 'package:spot/repositories/repository.dart';
import 'package:video_player/video_player.dart';

import '../components/app_scaffold.dart';

class ConfirmRecordingPage extends StatelessWidget {
  static Route<void> route({required XFile videoFile}) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ConfirmVideoCubit>(
        create: (context) => ConfirmVideoCubit(
            repository: RepositoryProvider.of<Repository>(context))
          ..initialize(videoFile: videoFile),
        child: ConfirmRecordingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocConsumer<ConfirmVideoCubit, ConfirmVideoState>(
        listener: (context, state) {
          if (state is ConfirmVideoUploaded) {
            Navigator.of(context).popUntil(
              (route) => route.settings.name == TabPage.name,
            );
          }
        },
        builder: (context, state) {
          if (state is ConfirmVideoInitial) {
            return preloader;
          } else if (state is ConfirmVideoPlaying) {
            return _VideoConfirmationPage(
              videoPlayerController: state.videoPlayerController,
            );
          } else if (state is ConfirmVideoTranscoding) {
            return Stack(
              fit: StackFit.expand,
              children: [
                FullScreenVideoPlayer(
                  videoPlayerController: state.videoPlayerController,
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000).withOpacity(0.3),
                    ),
                    child: preloader,
                  ),
                ),
              ],
            );
          } else if (state is ConfirmVideoUploaded) {
            return preloader;
          } else if (state is ConfirmVideoState) {
            return const Center(
              child: Text('Error occured. Please retry'),
            );
          }
          throw UnimplementedError('Confirm Recording Page State not caught');
        },
      ),
    );
  }
}

class _VideoConfirmationPage extends StatefulWidget {
  _VideoConfirmationPage({
    Key? key,
    required VideoPlayerController videoPlayerController,
  })   : _videoPlayerController = videoPlayerController,
        super(key: key);

  final VideoPlayerController _videoPlayerController;

  @override
  __VideoConfirmationPageState createState() => __VideoConfirmationPageState();
}

class __VideoConfirmationPageState extends State<_VideoConfirmationPage> {
  bool _showDescriptionDialog = false;
  bool _showStartOverConfirmationDialog = false;

  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FullScreenVideoPlayer(
          videoPlayerController: widget._videoPlayerController,
        ),
        if (!_showDescriptionDialog) _startOverButton(context),
        if (!_showDescriptionDialog) _looksGoodButton(context),
        if (_showDescriptionDialog) _descriptionDialog(),
        if (_showStartOverConfirmationDialog)
          _startOverConfirmationDialog(context),
      ],
    );
  }

  Positioned _startOverButton(BuildContext context) {
    return Positioned(
      left: 24,
      bottom: MediaQuery.of(context).padding.bottom + 24,
      child: GradientButton(
        strokeWidth: 0,
        onPressed: () {
          setState(() {
            _showStartOverConfirmationDialog = true;
          });
        },
        child: Row(
          children: [
            const Icon(Icons.refresh),
            const SizedBox(width: 4),
            const Text('Start Over'),
          ],
        ),
      ),
    );
  }

  Positioned _looksGoodButton(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: MediaQuery.of(context).padding.bottom + 24,
      child: GradientButton(
        onPressed: () {
          setState(() {
            _showDescriptionDialog = true;
          });
        },
        child: Row(
          children: [
            const Icon(FeatherIcons.thumbsUp),
            const SizedBox(width: 4),
            const Text('Looks Good'),
          ],
        ),
      ),
    );
  }

  Positioned _descriptionDialog() {
    return Positioned.fill(
      child: FrostedDialog(
        hasBackdropShadow: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _descriptionController,
                autofocus: true,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Video Description',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GradientButton(
                  strokeWidth: 0,
                  onPressed: () {
                    setState(() {
                      _showDescriptionDialog = false;
                    });
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    BlocProvider.of<ConfirmVideoCubit>(context)
                        .post(description: _descriptionController.text);
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Positioned _startOverConfirmationDialog(BuildContext context) {
    return Positioned.fill(
      child: FrostedDialog(
        hasBackdropShadow: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Are you sure you want to start over? The video you took will be lost.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GradientButton(
                  strokeWidth: 0,
                  onPressed: () {
                    setState(() {
                      _showStartOverConfirmationDialog = false;
                    });
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  strokeWidth: 0,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(RecordPage.route());
                  },
                  child: const Text('Start Over'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
