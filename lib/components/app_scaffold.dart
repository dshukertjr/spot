import 'dart:ui';

import 'package:flutter/material.dart';

/// Scaffold with a beautiful gradient background just for this app.
class AppScaffold extends Scaffold {
  /// Scaffold with a beautiful gradient background just for this app.
  AppScaffold({
    PreferredSizeWidget? appBar,
    required Widget body,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    bool resizeToAvoidBottomInset = true,
  }) : super(
          appBar: appBar,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4B3199),
                      Color(0xFF2284A9),
                    ],
                  ),
                ),
              ),
              body,
            ],
          ),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        );
}
