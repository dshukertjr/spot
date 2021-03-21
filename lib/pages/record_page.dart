import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/gradient_border.dart';
import 'package:spot/cubits/record/record_cubit.dart';

import '../components/app_scaffold.dart';
import '../cubits/record/record_cubit.dart';

class RecordPage extends StatelessWidget {
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => BlocProvider<RecordCubit>(
        create: (_) => RecordCubit()..initialize(),
        child: RecordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocBuilder<RecordCubit, RecordState>(
        builder: (context, state) {
          if (state is RecordInitial) {
            return preloader;
          } else if (state is RecordReady) {
            return RecordPreview(
              controller: state.controller,
              isPaused: true,
            );
          } else if (state is RecordInProgress) {
            return RecordPreview(
              controller: state.controller,
              isPaused: false,
            );
          } else if (state is RecordPaused) {
            return RecordPreview(
              controller: state.controller,
              isPaused: true,
            );
          } else if (state is RecordCompleted) {
            return RecordPreview(
              controller: state.controller,
              isPaused: true,
            );
          } else if (state is RecordError) {
            return Center(child: Text(state.errorMessage));
          }
          return Container();
        },
      ),
    );
  }
}

@visibleForTesting
class RecordPreview extends StatefulWidget {
  const RecordPreview({
    Key? key,
    required CameraController controller,
    required bool isPaused,
  })   : _controller = controller,
        _isPaused = isPaused,
        super(key: key);

  final CameraController _controller;
  final bool _isPaused;

  @override
  _RecordPreviewState createState() => _RecordPreviewState();
}

class _RecordPreviewState extends State<RecordPreview> {
  bool _isPastMimimumDuration = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _cameraPreview(),
        _recordButton(context),
        _gauge(context),
        _completeButton(context),
      ],
    );
  }

  Positioned _completeButton(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: MediaQuery.of(context).padding.bottom + 24,
      child: SizedBox(
        height: 70,
        child: Center(
          child: _RecordingCompleteButton(
              isPastMimimumDuration: _isPastMimimumDuration),
        ),
      ),
    );
  }

  ClipRect _cameraPreview() {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            height: 1,
            child: AspectRatio(
              aspectRatio: 1 / widget._controller.value.aspectRatio,
              child: CameraPreview(widget._controller),
            ),
          ),
        ),
      ),
    );
  }

  Positioned _recordButton(BuildContext context) {
    return Positioned.fill(
      top: null,
      bottom: MediaQuery.of(context).padding.bottom + 24,
      child: Center(
        child: SizedBox(
          width: 70,
          height: 70,
          child: GradientBorder(
            borderRadius: 100,
            strokeWidth: 3,
            gradient: blueGradient,
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                onTap: () {
                  if (widget._isPaused) {
                    BlocProvider.of<RecordCubit>(context).startRecording();
                  } else {
                    BlocProvider.of<RecordCubit>(context).pauseRecording();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: _RecordButtonTarget(
                      isPaused: widget._isPaused,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Displayes the gauge as well as stops the video recording
  /// when the gauge goes to the end
  Positioned _gauge(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: GradientBorder(
              borderRadius: 50,
              strokeWidth: 1,
              gradient: const LinearGradient(
                colors: [
                  appRed,
                  appOrange,
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: _RecordingGaugeIndicator(
                  isPaused: widget._isPaused,
                  onPastMinimumDuration: () {
                    setState(() {
                      _isPastMimimumDuration = true;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingCompleteButton extends StatefulWidget {
  const _RecordingCompleteButton({
    Key? key,
    required bool isPastMimimumDuration,
  })   : _isPastMimimumDuration = isPastMimimumDuration,
        super(key: key);

  final bool _isPastMimimumDuration;

  @override
  __RecordingCompleteButtonState createState() =>
      __RecordingCompleteButtonState();
}

class __RecordingCompleteButtonState extends State<_RecordingCompleteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _curve;
  bool _animationPlayed = false;

  static const _animationDuration = Duration(milliseconds: 80);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget._isPastMimimumDuration ? 1 : 0.5,
      child: AnimatedBuilder(
          animation: _curve,
          child: Material(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              onTap: widget._isPastMimimumDuration
                  ? () {
                      ///TODO open description window
                    }
                  : null,
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: redOrangeGradient,
                ),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          builder: (context, child) {
            return Transform.scale(
              scale: _curve.value,
              child: child,
            );
          }),
    );
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
      lowerBound: 0.8,
      upperBound: 1.0,
    );
    _curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _RecordingCompleteButton oldWidget) {
    _playAnimation();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    if (widget._isPastMimimumDuration && !_animationPlayed) {
      _animationPlayed = true;
      await _animationController.forward();
      await Future.delayed(_animationDuration);
      await _animationController.reverse();
    }
  }
}

class _RecordingGaugeIndicator extends StatefulWidget {
  const _RecordingGaugeIndicator({
    Key? key,
    required bool isPaused,
    required void Function() onPastMinimumDuration,
  })   : _onPastMinimumDuration = onPastMinimumDuration,
        _isPaused = isPaused,
        super(key: key);

  final bool _isPaused;
  final void Function() _onPastMinimumDuration;

  @override
  __RecordingGaugeIndicatorState createState() =>
      __RecordingGaugeIndicatorState();
}

class __RecordingGaugeIndicatorState extends State<_RecordingGaugeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: blueGradient,
          ),
          child: const SizedBox(height: 16),
        ),
        builder: (_, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animationController.value,
            child: child,
          );
        });
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _animationController
      ..addStatusListener(_checkComplete)
      ..addListener(_checkForMinimumDuration);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _RecordingGaugeIndicator oldWidget) {
    final isPausedChanged = widget._isPaused != oldWidget._isPaused;
    if (isPausedChanged) {
      if (widget._isPaused) {
        _animationController.stop();
      } else {
        _animationController.forward();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController
      ..removeStatusListener(_checkComplete)
      ..removeListener(_checkForMinimumDuration)
      ..dispose();
    super.dispose();
  }

  void _checkComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      BlocProvider.of<RecordCubit>(context).doneRecording();
    }
  }

  void _checkForMinimumDuration() {
    // If the video recording is above 20% of the max time
    // (6 seconds), then allow saving
    if (_animationController.value > 0.3) {
      widget._onPastMinimumDuration();
    }
  }
}

class _RecordButtonTarget extends StatefulWidget {
  const _RecordButtonTarget({
    Key? key,
    required bool isPaused,
  })   : _isRecording = isPaused,
        super(key: key);

  final bool _isRecording;

  @override
  __RecordButtonTargetState createState() => __RecordButtonTargetState();
}

class __RecordButtonTargetState extends State<_RecordButtonTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _curve,
        builder: (_, __) {
          return SizedBox(
            width: 50 - 20 * _curve.value,
            height: 50 - 20 * _curve.value,
            child: Ink(
              decoration: BoxDecoration(
                gradient: redOrangeGradient,
                borderRadius: BorderRadius.circular(25 - 19 * _curve.value),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    _curve =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _RecordButtonTarget oldWidget) {
    final isRecordingChanged = widget._isRecording != oldWidget._isRecording;
    if (isRecordingChanged) {
      if (widget._isRecording) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
