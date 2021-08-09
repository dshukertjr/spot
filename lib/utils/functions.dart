import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/pages/login_page.dart';
import 'package:spot/repositories/repository.dart';

class AuthRequired {
  static void action(BuildContext context, {required void Function() action}) {
    final userId = RepositoryProvider.of<Repository>(context).userId;
    if (userId != null) {
      action();
    } else {
      Navigator.of(context).push(LoginPage.route());
    }
  }
}
