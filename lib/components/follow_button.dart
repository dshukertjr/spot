import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/utils/functions.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    Key? key,
    required this.profile,
  }) : super(key: key);

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final isMyProfile =
        RepositoryProvider.of<Repository>(context).userId == profile.id;
    if (isMyProfile) {
      return const SizedBox();
    }
    return GradientButton(
      decoration: profile.isFollowing
          ? const BoxDecoration(gradient: redOrangeGradient)
          : null,
      onPressed: () {
        AuthRequired.action(context, action: () {
          if (profile.isFollowing) {
            BlocProvider.of<ProfileCubit>(context).unfollow(profile.id);
          } else {
            BlocProvider.of<ProfileCubit>(context).follow(profile.id);
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            profile.isFollowing
                ? FeatherIcons.userCheck
                : FeatherIcons.userPlus,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(profile.isFollowing ? 'Following' : 'Follow'),
        ],
      ),
    );
  }
}
