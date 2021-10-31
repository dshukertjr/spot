import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/components/user_profile.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/repositories/repository.dart';

/// Page that displays profile and past posts of a user.
class ProfilePage extends StatelessWidget {
  /// Page that displays profile and past posts of a user.
  const ProfilePage(this._userId, {Key? key}) : super(key: key);

  /// Name of this page within `RouteSettinngs`
  static const name = 'ProfilePage';

  /// Method ot create this page with necessary `BlocProvider`
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
