import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:spot/pages/edit_profile_page.dart';
import 'package:spot/utils/constants.dart';
import 'package:spot/components/frosted_dialog.dart';
import 'package:spot/components/gradient_button.dart';
import 'package:spot/repositories/repository.dart';

import '../components/app_scaffold.dart';

/// Indicates which dialog is currently openeds
@visibleForTesting
enum DialogPage {
  termsOfService,
  loginOrSignup,
  login,
  signUp,
}

class LoginPage extends StatefulWidget {
  static const name = 'LoginPage';
  static Route<void> route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: name),
      builder: (context) => LoginPage(),
    );
  }

  @override
  LoginPageState createState() => LoginPageState();
}

@visibleForTesting
class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final _purpleAnimationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..forward();

  late final _curvedAnimation = CurvedAnimation(
    parent: _purpleAnimationController,
    curve: Curves.easeOutCubic,
  );

  late final _yellowBlobAnimationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  late final _delayedCurvedAnimation = CurvedAnimation(
    parent: _yellowBlobAnimationController,
    curve: Curves.easeOutCubic,
  );

  late final _redBlobAnimationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  late final _moreDdelayedCurvedAnimation = CurvedAnimation(
    parent: _redBlobAnimationController,
    curve: Curves.easeOutCubic,
  );

  @visibleForTesting
  DialogPage currentDialogPage = DialogPage.loginOrSignup;

  double _dialogOpacity = 1;
  static const _dialogOpacityAnimationDuration = Duration(milliseconds: 200);

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -53,
              right: -47,
              child: AnimatedBuilder(
                  animation: _purpleAnimationController,
                  child: Image.asset(
                    'assets/images/purple-fog.png',
                    height: 228,
                  ),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _purpleAnimationController.value,
                      child: child,
                    );
                  }),
            ),
            Positioned(
              top: 201,
              left: 0,
              child: AnimatedBuilder(
                  animation: _curvedAnimation,
                  child: Image.asset(
                    'assets/images/blue-ellipse.png',
                    height: 168,
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(-200 + 200 * _curvedAnimation.value, 0),
                      child: child,
                    );
                  }),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 37,
              child: AnimatedBuilder(
                animation: _curvedAnimation,
                child: Image.asset('assets/images/blue-blob.png'),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      200 - 200 * _curvedAnimation.value,
                      400 - 400 * _curvedAnimation.value,
                    ),
                    child: child,
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 46,
              child: AnimatedBuilder(
                animation: _delayedCurvedAnimation,
                child: Image.asset('assets/images/yellow-blob.png'),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -300 + 300 * _delayedCurvedAnimation.value,
                      400 - 400 * _curvedAnimation.value,
                    ),
                    child: child,
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _moreDdelayedCurvedAnimation,
                child: Image.asset('assets/images/red-blob.png'),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      300 - 300 * _moreDdelayedCurvedAnimation.value,
                    ),
                    child: child,
                  );
                },
              ),
            ),
            FrostedDialog(
              child: AnimatedOpacity(
                duration: _dialogOpacityAnimationDuration,
                opacity: _dialogOpacity,
                child: _isLoading
                    ? const SizedBox(
                        height: 150,
                        child: preloader,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentDialogPage == DialogPage.termsOfService)
                            ..._termsOfService(),
                          if (currentDialogPage == DialogPage.loginOrSignup)
                            ..._loginOrSignup(),
                          if (currentDialogPage == DialogPage.login)
                            ..._login(),
                          if (currentDialogPage == DialogPage.signUp)
                            ..._signUp(),
                        ],
                      ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _playDelayedAnimation();
    _checkTermsOfServiceAgreement();
    super.initState();
  }

  @override
  void dispose() {
    _purpleAnimationController.dispose();
    _yellowBlobAnimationController.dispose();
    _redBlobAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkTermsOfServiceAgreement() async {
    final agreed = await RepositoryProvider.of<Repository>(context)
        .hasAgreedToTermsOfService;
    if (!agreed) {
      setState(() {
        currentDialogPage = DialogPage.termsOfService;
      });
    }
  }

  List<Widget> _termsOfService() {
    return [
      const Text(
        'Sign in to continue!',
        style: TextStyle(fontSize: 24),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 300,
        child: FutureBuilder(
          future: rootBundle.loadString('assets/md/terms_of_service.md'),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              final mdData = snapshot.data;
              if (mdData == null) {
                return const Center(
                  child: Text('Error loading Terms of Service'),
                );
              }
              return Markdown(data: mdData);
            }
            return preloader;
          },
        ),
      ),
      const SizedBox(height: 8),
      GradientButton(
        onPressed: () async {
          setState(() {
            currentDialogPage = DialogPage.loginOrSignup;
          });
          await RepositoryProvider.of<Repository>(context)
              .agreedToTermsOfService();
        },
        child: const Center(child: Text('Agree')),
      ),
    ];
  }

  List<Widget> _loginOrSignup() {
    return [
      const Text(
        'Would you like to...',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(height: 24.5),
      _LoginButton(
        label: 'Sign in',
        onPressed: () {
          _doSomethingWithinFadeDialog(action: () {
            setState(() {
              currentDialogPage = DialogPage.login;
            });
          });
        },
      ),
      const SizedBox(height: 24.5),
      _LoginButton(
        label: 'Create an Account',
        onPressed: () {
          _doSomethingWithinFadeDialog(action: () {
            setState(() {
              currentDialogPage = DialogPage.signUp;
            });
          });
        },
      ),
    ];
  }

  List<Widget> _login() {
    return [
      Row(
        children: [
          IconButton(
            icon: const Icon(FeatherIcons.chevronLeft),
            onPressed: () {
              _doSomethingWithinFadeDialog(action: () {
                setState(() {
                  currentDialogPage = DialogPage.loginOrSignup;
                });
              });
            },
          ),
          const Expanded(
            child: Text(
              'Sign in',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24.5),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(
            FeatherIcons.mail,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      const SizedBox(height: 24.5),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(
            FeatherIcons.lock,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      const SizedBox(height: 24.5),
      _LoginButton(
        label: 'Sign in',
        onPressed: () async {
          try {
            setState(() {
              _isLoading = true;
            });
            final repository = RepositoryProvider.of<Repository>(context)
              ..statusKnown = Completer<void>();
            final persistSessionString = await repository.signIn(
                email: _emailController.text,
                password: _passwordController.text);
            // Store current session
            await repository.setSessionString(persistSessionString);
            await repository.statusKnown.future;
            final myProfile = repository.myProfile;
            if (myProfile == null) {
              await Navigator.of(context).pushReplacement(
                  EditProfilePage.route(isCreatingAccount: true));
            } else {
              Navigator.of(context).pop();
            }
          } on PlatformException catch (err) {
            setState(() {
              _isLoading = false;
            });
            context.showErrorSnackbar(err.message ?? 'Error signing in');
            return;
          } catch (err) {
            setState(() {
              _isLoading = false;
            });
            context.showErrorSnackbar('Error signing in');
          }
        },
      ),
    ];
  }

  List<Widget> _signUp() {
    return [
      Row(
        children: [
          IconButton(
            icon: const Icon(FeatherIcons.chevronLeft),
            onPressed: () {
              _doSomethingWithinFadeDialog(action: () {
                setState(() {
                  currentDialogPage = DialogPage.loginOrSignup;
                });
              });
            },
          ),
          const Expanded(
            child: Text(
              'Create an Account',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24.5),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(
            FeatherIcons.mail,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      const SizedBox(height: 24.5),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(
            FeatherIcons.lock,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      const SizedBox(height: 24.5),
      _LoginButton(
        label: 'Sign Up',
        onPressed: () async {
          try {
            setState(() {
              _isLoading = true;
            });
            final persistSessionString =
                await RepositoryProvider.of<Repository>(context).signUp(
                    email: _emailController.text,
                    password: _passwordController.text);

            // Store current session
            await RepositoryProvider.of<Repository>(context)
                .setSessionString(persistSessionString);

            await Navigator.of(context).pushReplacement(
                EditProfilePage.route(isCreatingAccount: true));
          } on PlatformException catch (err) {
            setState(() {
              _isLoading = false;
            });
            context.showSnackbar(err.message ?? 'Error signing up');
          } catch (err) {
            setState(() {
              _isLoading = false;
            });
            context.showErrorSnackbar('Error signing up');
          }
        },
      ),
      const SizedBox(height: 24.5),
      const Text(
        'By signing in, you agree to the Terms of Service and Privacy Policy',
      ),
    ];
  }

  Future<void> _playDelayedAnimation() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _yellowBlobAnimationController..forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _redBlobAnimationController..forward();
  }

  Future<void> _doSomethingWithinFadeDialog(
      {required void Function() action}) async {
    setState(() {
      _dialogOpacity = 0;
    });
    await Future.delayed(_dialogOpacityAnimationDuration);
    action();
    await Future.delayed(_dialogOpacityAnimationDuration);
    setState(() {
      _dialogOpacity = 1;
    });
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton(
      {Key? key, required void Function() onPressed, required String label})
      : _onPressed = onPressed,
        _label = label,
        super(key: key);

  final void Function() _onPressed;
  final String _label;

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: _onPressed,
      child: Text(
        _label,
        textAlign: TextAlign.center,
      ),
    );
  }
}
