import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spot/repositories/repository.dart';

class MockRepository extends Mock implements Repository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp({
    required Widget widget,
    required Repository repository,
  }) {
    return pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<Repository>(
            create: (context) => repository,
          ),
        ],
        child: MaterialApp(
          home: widget,
        ),
      ),
    );
  }
}
