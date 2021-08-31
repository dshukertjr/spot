import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/components/user_profile.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/repositories/repository.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage(this._userId, {Key? key}) : super(key: key);

  static const name = 'ProfilePage';

  static Route<void> route(String userId) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: name),
      builder: (_) => BlocProvider<ProfileCubit>(
        create: (context) => ProfileCubit(
          repository: RepositoryProvider.of<Repository>(context),
        )..loadProfile(userId),
        child: ProfilePage(userId),
      ),
    );
  }

  final String _userId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title:
            BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
          if (state is ProfileLoaded) {
            return Text(state.profile.name);
          }
          return const SizedBox();
        }),
      ),
      body: UserProfile(userId: _userId),
    );
  }
}
