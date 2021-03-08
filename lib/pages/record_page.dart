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
      ),
      body: BlocBuilder<RecordCubit, RecordState>(
        builder: (context, state) {
          if (state is RecordInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecordInProgress) {
            return CameraPreview(state.controller);
          }
          return Container();
        },
      ),
    );
  }
}
