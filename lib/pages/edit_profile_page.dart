import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/cubits/profile/profile_cubit.dart';
import 'package:spot/repositories/repository.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/utils/validators.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    Key? key,
    required this.isCreatingAccount,
  }) : super(key: key);

  final bool isCreatingAccount;

  static const name = 'EditProfilePage';

  static Route<void> route({
    required bool isCreatingAccount,
  }) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: name),
      builder: (context) => BlocProvider<ProfileCubit>(
        create: (context) => ProfileCubit(
          repository: RepositoryProvider.of<Repository>(context),
        )..loadMyProfileIfExists(),
        child: EditProfilePage(
          isCreatingAccount: isCreatingAccount,
        ),
      ),
    );
  }

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _userNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _currentProfileImageUrl;
  File? _selectedImageFile;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            final profile = state.profile;
            setState(() {
              _userNameController.text = profile.name;
              _descriptionController.text = profile.description ?? '';
              _currentProfileImageUrl = profile.imageUrl;
            });
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return preloader;
          } else if (state is ProfileLoaded ||
              state is ProfileNotFound ||
              state is ProfileError) {
            return _form(context);
          }
          return preloader;
        },
      ),
    );
  }

  Form _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(19)
            .copyWith(top: 19 + MediaQuery.of(context).padding.top),
        children: [
          Row(
            children: [
              ClipOval(
                child: GestureDetector(
                  onTap: () async {
                    try {
                      final pickedImage = await ImagePicker().getImage(
                        source: ImageSource.gallery,
                        maxWidth: 360,
                        maxHeight: 360,
                        imageQuality: 75,
                      );
                      if (pickedImage == null) {
                        return;
                      }
                      setState(() {
                        _selectedImageFile = File(pickedImage.path);
                      });
                    } catch (e) {
                      context.showErrorSnackbar('Error while selecting image');
                    }
                  },
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: _profileImage(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _userNameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'User Name',
                  ),
                  maxLength: 18,
                  validator: Validator.username,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Bio',
            ),
            maxLength: 320,
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!widget.isCreatingAccount) ...[
                GradientButton(
                  strokeWidth: 0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
              ],
              GradientButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  try {
                    final user =
                        RepositoryProvider.of<Repository>(context).userId;
                    if (user == null) {
                      context.showErrorSnackbar('Your session has expired');
                      return;
                    }
                    final name = _userNameController.text;
                    final description = _descriptionController.text;

                    await BlocProvider.of<ProfileCubit>(context).saveProfile(
                      name: name,
                      description: description,
                      imageFile: _selectedImageFile,
                    );
                    if (widget.isCreatingAccount) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                    }
                  } catch (err) {
                    context.showErrorSnackbar(
                        'Error occured while saving profile');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileImage() {
    if (_selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
      );
    } else if (_currentProfileImageUrl != null) {
      return Image.network(
        _currentProfileImageUrl!,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/user.png',
        fit: BoxFit.cover,
      );
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
