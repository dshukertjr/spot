import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/pages/tab_page.dart';
import 'package:spot/repositories/repository.dart';

import '../components/app_scaffold.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => SplashPage());
  }

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: preloader,
    );
  }

  @override
  void initState() {
    _redirect();
    super.initState();
  }

  Future<void> _restoreSession() async {
    final hasSession = await RepositoryProvider.of<Repository>(context).hasSession();
    if (!hasSession) {
      return;
    }

    final jsonStr = await RepositoryProvider.of<Repository>(context).getSessionString();
    if (jsonStr == null) {
      await RepositoryProvider.of<Repository>(context).deleteSession();
      return;
    }
    final session = await RepositoryProvider.of<Repository>(context).recoverSession(jsonStr);

    if (session == null) {
      await RepositoryProvider.of<Repository>(context).deleteSession();
      return;
    }

    await RepositoryProvider.of<Repository>(context).setSessionString(session.persistSessionString);
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _restoreSession();

    /// Check Auth State
    final userId = RepositoryProvider.of<Repository>(context).userId;
    if (userId == null) {
      _redirectToLoginPage();
      return;
    }
    try {
      final profile = await RepositoryProvider.of<Repository>(context).getSelfProfile();
      if (profile == null) {
        _redirectToEditProfilePage(userId);
        return;
      }
      _redirectToTabsPage();
    } catch (err) {
      await RepositoryProvider.of<Repository>(context).deleteSession();
      _redirectToLoginPage();
    }
  }

  void _redirectToLoginPage() {
    Navigator.of(context).pushReplacement(LoginPage.route());
  }

  void _redirectToEditProfilePage(String uid) {
    Navigator.of(context).pushReplacement(
      EditProfilePage.route(isCreatingAccount: true, uid: uid),
    );
  }

  void _redirectToTabsPage() {
    Navigator.of(context).pushReplacement(TabPage.route());
  }
}
