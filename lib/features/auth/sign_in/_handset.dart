import 'package:auto_route/auto_route.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/auth/cubit/google_sign_in_cubit.dart';
import 'package:leadership/features/auth/cubit/sign_in_cubit.dart';
import 'package:leadership/features/auth/cubit/social_login_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/firebase_service.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';

class SignInHandset extends StatefulWidget {
  const SignInHandset({super.key});

  @override
  State<SignInHandset> createState() => _SignInHandsetState();
}

class _SignInHandsetState extends State<SignInHandset> {
  final _emailController = TextEditingController(
    text: kDebugMode ? 'approvals@parkroadfellowship.org' : '',
  );
  final _passwordController = TextEditingController(
    text: kDebugMode ? 'password' : '',
  );
  final _hidePasswordNotifier = ValueNotifier<bool>(true);

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocListener<GoogleSignInCubit, GoogleSignInState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loaded: (socialLoginDTO) => context.read<SocialLoginCubit>().login(
            socialAuthDTO: socialLoginDTO,
          ),
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        );
      },
      child: BlocListener<SocialLoginCubit, SocialLoginState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
            loaded: () =>
                context.router.pushPath(PRFLeadershipRouter.decisionRoute),
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          );
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),

                            // Logo
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ExtendedImage.asset(
                                  'assets/images/app-logo.png',
                                  height: 60,
                                  width: 69,
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),

                            // Welcome Text
                            Text(
                              l10n.signIn,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 32,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              l10n.welcomeBack,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 48),

                            FutureBuilder(
                              future: getIt<FirebaseService>().canShowAuth(),
                              builder: (context, snapshot) {
                                final canShowAuth = snapshot.data ?? false;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (canShowAuth || kDebugMode) ...[
                                      // Email Input
                                      PRFEmailInput(
                                        hintText: l10n.enterEmail,
                                        emailController: _emailController,
                                        enabled: !_isLoading,
                                      ),

                                      const SizedBox(height: 16),

                                      // Password Input
                                      PRFPasswordInput(
                                        hintText: l10n.enterPassword,
                                        hidePasswordNotifier:
                                            _hidePasswordNotifier,
                                        passwordController: _passwordController,
                                        enabled: !_isLoading,
                                      ),

                                      const SizedBox(height: 32),

                                      // Sign In Button
                                      BlocConsumer<SigninCubit, SignInState>(
                                        listener: (context, state) {
                                          state.maybeWhen(
                                            loading: () => setState(() {
                                              _isLoading = !_isLoading;
                                            }),
                                            loaded: () =>
                                                context.router.pushPath(
                                                  PRFLeadershipRouter
                                                      .landingRoute,
                                                ),
                                            error: (message) {
                                              setState(() {
                                                _isLoading = !_isLoading;
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(message),
                                                  backgroundColor:
                                                      theme.colorScheme.error,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                            orElse: () {},
                                          );
                                        },
                                        builder: (context, state) {
                                          return PRFPrimaryButton(
                                            onPressed: () {
                                              if (_emailController
                                                  .text
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.enterEmail,
                                                    ),
                                                    backgroundColor:
                                                        theme.colorScheme.error,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                                Gaimon.warning();
                                                return;
                                              }

                                              if (_passwordController
                                                  .text
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.enterPassword,
                                                    ),
                                                    backgroundColor:
                                                        theme.colorScheme.error,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                                Gaimon.warning();
                                                return;
                                              }

                                              context
                                                  .read<SigninCubit>()
                                                  .signIn(
                                                    email: _emailController.text
                                                        .trim(),
                                                    password:
                                                        _passwordController.text
                                                            .trim(),
                                                  );
                                            },
                                            title: _isLoading
                                                ? l10n.signingIn
                                                : l10n.signIn,
                                            disabled: _isLoading,
                                            isLoading: _isLoading,
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 32),

                                      // Divider
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: theme.colorScheme.outline,
                                              thickness: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(
                                              'OR',
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: theme.colorScheme.outline,
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 32),
                                    ],

                                    // Google Sign In Button
                                    const GoogleSignInButton(),
                                  ],
                                );
                              },
                            ),

                            const Spacer(),

                            // Version
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l10n.version(Misc.getAppVersion()),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoogleSignInCubit, GoogleSignInState>(
      builder: (context, signInWithGoogleState) {
        return BlocBuilder<SocialLoginCubit, SocialLoginState>(
          builder: (context, socialSignUpState) {
            return BlocBuilder<SocialLoginCubit, SocialLoginState>(
              builder: (context, socialSignInState) {
                final (
                  isLoading,
                  title,
                ) = signInWithGoogleState.maybeWhen(
                  loading: () => (true, 'Please wait ...'),
                  orElse: () => socialSignUpState.maybeWhen(
                    loading: () => (
                      true,
                      'Please wait ...',
                    ),
                    orElse: () => socialSignInState.maybeWhen(
                      loading: () => (
                        true,
                        'Please wait ...',
                      ),
                      orElse: () => (
                        false,
                        'Continue with Google',
                      ),
                    ),
                  ),
                );

                return GoogleAuthButton(
                  onPressed: () =>
                      context.read<GoogleSignInCubit>().signInwithGoogle(),
                  title: title,
                  disabled: isLoading,
                  isLoading: isLoading,
                );
              },
            );
          },
        );
      },
    );
  }
}
