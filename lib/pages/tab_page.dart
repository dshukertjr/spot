import 'package:flutter/material.dart';
import 'package:spot/components/gradient_border.dart';
import 'package:spot/pages/record_page.dart';
import 'package:spot/pages/tabs/map_tab.dart';
import 'package:spot/pages/tabs/notifications_tab.dart';
import 'package:spot/pages/tabs/profile_tab.dart';
import 'package:spot/pages/tabs/search_tab.dart';

import '../components/app_scaffold.dart';
import 'record_page.dart';

class TabPage extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => TabPage());
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
          MapTab(),
          SearchTab(),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomNavigationButton(
                  label: 'Home',
                  icon: const Icon(Icons.home),
                  tabIndex: 0,
                ),
                _bottomNavigationButton(
                  label: 'Search',
                  icon: const Icon(Icons.search),
                  tabIndex: 1,
                ),
                const _RecordButton(),
                _bottomNavigationButton(
                  label: 'Notifications',
                  icon: const Icon(Icons.notifications),
                  tabIndex: 0,
                ),
                _bottomNavigationButton(
                  label: 'Profile',
                  icon: ClipOval(
                    child: Image.network(
                      'https://www.dmarge.com/wp-content/uploads/2021/01/dwayne-the-rock-.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  tabIndex: 0,
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
    return InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: icon,
          ),
          const SizedBox(height: 4.5),
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
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientBorder(
      strokeWidth: 2,
      borderRadius: 12,
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF3790E3),
          Color(0xFF43CBE9),
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
                Color(0xFFD73763),
                Color(0xFFF6935C),
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
    );
  }
}
