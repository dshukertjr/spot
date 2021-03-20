import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/gradient_border.dart';
import 'package:spot/cubits/record/record_cubit.dart';

import '../components/app_scaffold.dart';

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
class RecordPreview extends StatelessWidget {
  const RecordPreview({
    Key? key,
    required this.controller,
    required this.isPaused,
  }) : super(key: key);

  final CameraController controller;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _cameraPreview(),
        _recordButton(context),
        _gauge(context),
      ],
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
              aspectRatio: 1 / controller.value.aspectRatio,
              child: CameraPreview(controller),
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
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              onTap: () {
                if (isPaused) {
                  BlocProvider.of<RecordCubit>(context).startRecording();
                } else {
                  BlocProvider.of<RecordCubit>(context).pauseRecording();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(isPaused ? 100 : 8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.01,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appBlue,
                          appLightBlue,
                        ],
                      ),
                    ),
                    child: SizedBox(height: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
