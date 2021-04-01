import 'package:flutter/material.dart';
import 'package:spot/app/constants.dart';
import 'package:spot/components/app_scaffold.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/models/profile.dart';
import 'package:spot/pages/splash_page.dart';

class EditProfilePage extends StatefulWidget {
  final bool isCreatingAccount;

  const EditProfilePage({
    Key? key,
    required this.isCreatingAccount,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _userNameController = TextEditingController();
  final _bioController = TextEditingController();

  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: _isLoading
          ? preloader
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(19)
                    .copyWith(top: 19 + MediaQuery.of(context).padding.top),
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          'https://www.muscleandfitness.com/wp-content/uploads/2015/08/what_makes_a_man_more_manly_main0.jpg?quality=86&strip=all',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _userNameController,
                          decoration: const InputDecoration(
                            labelText: 'User Name',
                          ),
                          maxLength: 18,
                          validator: (val) {
                            if (val == null) {
                              return 'Please enter more then 4 letters';
                            }
                            if (val.length < 4) {
                              return 'Please enter more then 4 letters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _bioController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                    ),
                    maxLength: 320,
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GradientButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            final user = supabaseClient.auth.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Your session has expired')));
                              return;
                            }
                            final name = _userNameController.text;
                            final description = _bioController.text;
                            final res =
                                await supabaseClient.from('users').insert([
                              Profile.toMap(
                                id: user.id,
                                name: name,
                                description: description,
                              )
                            ]).execute();
                            final error = res.error;
                            if (error != null) {
                              setState(() {
                                _isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.message)));
                              return;
                            }
                            await Navigator.of(context)
                                .pushReplacement(SplashPage.route());
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Error occured while saving profile')));
                          }
                        },
                        child: const Text('Save')),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
