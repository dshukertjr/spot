import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/gradient_border.dart';
import 'package:spot/pages/record_page.dart';
import 'package:spot/pages/tabs/map_tab.dart';
import 'package:spot/pages/tabs/notifications_tab.dart';
import 'package:spot/pages/tabs/profile_tab.dart';
import 'package:spot/pages/tabs/search_tab.dart';

import '../components/app_scaffold.dart';
import 'record_page.dart';

class TabPage extends StatefulWidget {
  static const name = 'TabPage';
  static Route<void> route() {
    return MaterialPageRoute(
      settings: const RouteSettings(
        name: name,
      ),
      builder: (_) => TabPage(),
    );
  }

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MapTab.create(),
          SearchTab.create(),
          NotificationsTab(),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                const _RecordButton(),
                _bottomNavigationButton(
                  label: 'Notifications',
                  icon: const Icon(
                    FeatherIcons.bell,
                    size: 22,
                  ),
                  tabIndex: 2,
                ),
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
  }) {
    return Expanded(
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: icon,
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
        onTap: () {
          setState(() {
            _currentIndex = tabIndex;
          });
        },
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
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
                onTap: () {
                  Navigator.of(context).push(RecordPage.route());
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
