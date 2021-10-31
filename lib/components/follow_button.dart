import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/utils/functions.dart';

/// Button where users can follow or unfollow other users
class FollowButton extends StatelessWidget {
  /// Button where users can follow or unfollow other users
  const FollowButton({
    Key? key,
    required Profile profile,
  })  : _profile = profile,
        super(key: key);

  final Profile _profile;

  @override
  Widget build(BuildContext context) {
    final isMyProfile =
        RepositoryProvider.of<Repository>(context).userId == _profile.id;
    if (isMyProfile) {
      return const SizedBox();
    }
    return GradientButton(
      decoration: _profile.isFollowing
          ? const BoxDecoration(gradient: redOrangeGradient)
          : null,
      onPressed: () {
        AuthRequired.action(context, action: () {
          if (_profile.isFollowing) {
            BlocProvider.of<ProfileCubit>(context).unfollow(_profile.id);
          } else {
            BlocProvider.of<ProfileCubit>(context).follow(_profile.id);
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _profile.isFollowing
                ? FeatherIcons.userCheck
                : FeatherIcons.userPlus,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(_profile.isFollowing ? 'Following' : 'Follow'),
        ],
      ),
    );
  }
}
