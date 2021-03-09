import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/cubits/record/record_cubit.dart';

class RecordPage extends StatelessWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => RecordPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: BlocBuilder<RecordCubit, RecordState>(
        builder: (context, state) {
          if (state is RecordInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecordReady) {
            return _RecordPreview(
              controller: state.controller,
              isPaused: true,
            );
          } else if (state is RecordInProgress) {
            return _RecordPreview(
              controller: state.controller,
              isPaused: false,
            );
          } else if (state is RecordPaused) {
            return _RecordPreview(
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

class _RecordPreview extends StatelessWidget {
  const _RecordPreview({
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
        ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
        Positioned.fill(
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
                        borderRadius: BorderRadius.circular(isPaused ? 8 : 100),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
