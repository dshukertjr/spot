import 'package:flutter/material.dart';
import 'package:spot/pages/tabs/map_tab.dart';
import 'package:spot/pages/tabs/profile_tab.dart';

enum _Tab {
  map,
  profile,
}

class TabPage extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => TabPage());
  }

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  _Tab _currentTab = _Tab.map;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          MapTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomNavigationButton(_Tab.map),
          _bottomNavigationButton(_Tab.profile),
        ],
      ),
    );
  }

  IconButton _bottomNavigationButton(_Tab tab) {
    late IconData iconData;
    if (tab == _Tab.map) {
      iconData = Icons.home;
    } else if (tab == _Tab.profile) {
      iconData = Icons.person;
    }
    return IconButton(
      icon: Icon(iconData),
      onPressed: () {
        setState(() {
          _currentTab = tab;
        });
      },
    );
  }
}
