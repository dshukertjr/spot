import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/repositories/repository.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<Repository>(
            create: (context) => Repository(),
          ),
        ],
        child: MaterialApp(
          home: widget,
        ),
      ),
    );
  }
}
