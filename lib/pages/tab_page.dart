import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/components/frosted_dialog.dart';
import 'package:spot/components/gradient_border.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/components/notification_dot.dart';
import 'package:spot/cubits/notification/notification_cubit.dart';
import 'package:spot/pages/record_page.dart';
import 'package:spot/pages/tabs/map_tab.dart';
import 'package:spot/pages/tabs/notifications_tab.dart';
import 'package:spot/pages/tabs/profile_tab.dart';
import 'package:spot/pages/tabs/search_tab.dart';
import 'package:spot/pages/view_video_page.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/utils/functions.dart';
import 'package:uni_links/uni_links.dart';

import '../components/app_scaffold.dart';
import 'record_page.dart';

/// Page that holds tab navigation at the bottom.
/// This is the first page presented to the user.
class TabPage extends StatefulWidget {
  /// Name of this page within `RouteSettinngs`
  static const name = 'TabPage';

  /// Method ot create this page with necessary `BlocProvider`
  static Route<void> route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: name),
      builder: (_) => TabPage(),
    );
  }

  @override
  TabPageState createState() => TabPageState();
}

@visibleForTesting

/// State of `TabPage`. Made public for testing purposes.
class TabPageState extends State<TabPage> {
  /// Currently shown tab index. Initially set to show the MapTab.
  @visibleForTesting
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: currentIndex,
        children: [
          MapTab.create(),
          SearchTab.create(),
          NotificationsTab.create(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: Material(
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF40489D),
                Color(0xFF2D6FA5),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              children: [
                _bottomNavigationButton(
                  label: 'Home',
                  icon: const Icon(
                    FeatherIcons.home,
                    size: 22,
                  ),
                  tabIndex: 0,
                ),
                _bottomNavigationButton(
                  label: 'Search',
                  icon: const Icon(
                    FeatherIcons.search,
                    size: 22,
                  ),
                  tabIndex: 1,
                ),
                const RecordButton(),
                BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                  var hasNewNotifications = false;
                  if (state is NotificationLoaded && state.hasNewNotification) {
                    hasNewNotifications = true;
                  }
                  return _bottomNavigationButton(
                    label: 'Notifications',
                    icon: const Icon(
                      FeatherIcons.bell,
                      size: 22,
                    ),
                    tabIndex: 2,
                    withDot: hasNewNotifications,
                    onPressed: () {
                      // Update the last seen notification
                      BlocProvider.of<NotificationCubit>(context)
                          .updateTimestampOfLastSeenNotification();
                    },
                  );
                }),
                _bottomNavigationButton(
                  label: 'Profile',
                  icon: const Icon(
                    FeatherIcons.user,
                    size: 22,
                  ),
                  tabIndex: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigationButton({
    required String label,
    required Widget icon,
    required int tabIndex,
    bool withDot = false,
    void Function()? onPressed,
  }) {
    return Expanded(
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: icon,
                ),
                if (withDot)
                  const Positioned(
                    top: -2,
                    right: -2,
                    child: NotificationDot(),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        onTap: () async {
          if (tabIndex == 2 || tabIndex == 3) {
            await AuthRequired.action(context, action: () {
              setState(() {
                currentIndex = tabIndex;
              });
              if (onPressed != null) onPressed();
            });
          } else {
            setState(() {
              currentIndex = tabIndex;
            });
            if (onPressed != null) onPressed();
          }
        },
      ),
    );
  }

  /// Called when the app comes back from background mode.
  Future<void> onResumed() async {
    await RepositoryProvider.of<Repository>(context).recoverSession();
  }

  @override
  void initState() {
    super.initState();
    _setupAppLinks();
    WidgetsBinding.instance
        ?.addObserver(LifecycleEventHandler(resumeCallBack: onResumed));
  }

  Future<void> _setupAppLinks() async {
    /// Quick and dirty way of
    /// waiting until TabPage gets added to the widget tree.
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final initialUri = await getInitialUri();
      _handleAppLink(initialUri);
      uriLinkStream.listen(_handleAppLink);
    } catch (_) {
      context.showErrorSnackbar('Error opening the video.');
    }
  }

  void _handleAppLink(Uri? uri) {
    if (uri != null) {
      final path = uri.path;
      if (path.split('/').first == 'post') {
        final videoId = path.split('/').last;
        Navigator.of(context).push(ViewVideoPage.route(videoId: videoId));
      }
    }
  }
}

/// Class to listen to app lifecycle such as background and foreground.
/// Listening to app lifecycle is necessary to keep auth state.
class LifecycleEventHandler extends WidgetsBindingObserver {
  /// Class to listen to app lifecycle such as background and foreground.
  /// Listening to app lifecycle is necessary to keep auth state.
  LifecycleEventHandler({
    required this.resumeCallBack,
  });

  /// Method to be called when the app comes back to foreground.
  final AsyncCallback resumeCallBack;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
    }
  }
}

@visibleForTesting

/// Button that opens `RecordPage`.
class RecordButton extends StatelessWidget {
  /// Button that opens `RecordPage`.
  const RecordButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        heightFactor: 1,
        child: GradientBorder(
          strokeWidth: 2,
          borderRadius: 12,
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              appBlue,
              appLightBlue,
            ],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.hardEdge,
            child: Ink(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    appRed,
                    appOrange,
                  ],
                ),
              ),
              child: InkWell(
                onTap: () async {
                  await AuthRequired.action(context, action: () async {
                    final hasLocationPermission =
                        await RepositoryProvider.of<Repository>(context)
                            .hasLocationPermission();
                    if (hasLocationPermission) {
                      await Navigator.of(context).push(RecordPage.route());
                    } else {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return FrostedDialog(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Your location permission is off',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text('Please grant location '
                                    'permission to post a video. '),
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
                                        final couldOpen =
                                            await RepositoryProvider.of<
                                                    Repository>(context)
                                                .openLocationSettingsPage();
                                        if (!couldOpen) {
                                          context.showErrorSnackbar(
                                              'Failed to open settings page. ');
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Open Settings'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
