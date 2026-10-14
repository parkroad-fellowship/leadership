import 'package:auto_route/auto_route.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/di/di_container.dart';
import 'package:leadership/features/auth/cubit/google_sign_in_cubit.dart';
import 'package:leadership/features/auth/cubit/sign_in_cubit.dart';
import 'package:leadership/features/auth/cubit/social_login_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/firebase_service.dart';
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/router/router.dart';
import 'package:prf_design/prf_design.dart';

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
          error: (_) {
            PRFSnackbar.error(context, l10n.authGoogleSignInFailed);
          },
        );
      },
      child: BlocListener<SocialLoginCubit, SocialLoginState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
            loaded: () =>
                context.router.pushPath(PRFLeadershipRouter.decisionRoute),
            error: (_) {
              PRFSnackbar.error(context, l10n.authGoogleSignInFailed);
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
                        padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),

                            // Logo
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(
                                  PRFSpacingTokens.lg,
                                ),
                                decoration: BoxDecoration(
                                  // Fixed white plate: the logo artwork is
                                  // drawn for a light background in both modes.
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.lg,
                                  ),
                                  boxShadow: PRFShadowTokens.card(
                                    theme.colorScheme.shadow,
                                  ),
                                ),
                                child: ExtendedImage.asset(
                                  'assets/images/app-logo.png',
                                  height: 60,
                                  width: 69,
                                ),
                              ),
                            ),

                            const SizedBox(height: PRFSpacingTokens.xxxl),

                            // Welcome Text
                            Text(
                              l10n.signIn,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: PRFSpacingTokens.sm),

                            Text(
                              l10n.welcomeBack,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: PRFSpacingTokens.xxxl),

                            FutureBuilder(
                              future: getIt<PRFFirebaseService>().canShowAuth(),
                              builder: (context, snapshot) {
                                final canShowAuth = snapshot.data ?? false;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (canShowAuth || kDebugMode) ...[
                                      // Email Input
                                      PRFTextField(
                                        hintText: l10n.enterEmail,
                                        labelText: l10n.email,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        controller: _emailController,
                                        type: PRFTextFieldType.email,
                                        enabled: !_isLoading,
                                      ),

                                      const SizedBox(
                                        height: PRFSpacingTokens.lg,
                                      ),

                                      // Password Input
                                      PRFTextField(
                                        hintText: l10n.enterPassword,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        obscureNotifier: _hidePasswordNotifier,
                                        controller: _passwordController,
                                        type: PRFTextFieldType.password,
                                        enabled: !_isLoading,
                                      ),

                                      const SizedBox(
                                        height: PRFSpacingTokens.xxxl,
                                      ),

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
                                            error: (_) {
                                              setState(() {
                                                _isLoading = !_isLoading;
                                              });
                                              PRFSnackbar.error(
                                                context,
                                                l10n.authSignInFailed,
                                              );
                                            },
                                            orElse: () {},
                                          );
                                        },
                                        builder: (context, state) {
                                          return PRFButton(
                                            onPressed: () {
                                              if (_emailController
                                                  .text
                                                  .isEmpty) {
                                                PRFSnackbar.error(
                                                  context,
                                                  l10n.authEnterEmail,
                                                );
                                                Gaimon.warning();
                                                return;
                                              }

                                              if (_passwordController
                                                  .text
                                                  .isEmpty) {
                                                PRFSnackbar.error(
                                                  context,
                                                  l10n.authEnterPassword,
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

                                      const SizedBox(
                                        height: PRFSpacingTokens.xxxl,
                                      ),

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
                                              horizontal: PRFSpacingTokens.lg,
                                            ),
                                            child: Text(
                                              l10n.authOr.toUpperCase(),
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontWeight: FontWeight.w600,
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

                                      const SizedBox(
                                        height: PRFSpacingTokens.xxxl,
                                      ),
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
                                  horizontal: PRFSpacingTokens.lg,
                                  vertical: PRFSpacingTokens.sm,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.xl,
                                  ),
                                ),
                                child: Text(
                                  l10n.version(Misc.getAppVersion()),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoogleSignInCubit, GoogleSignInState>(
      builder: (context, signInWithGoogleState) {
        return BlocBuilder<SocialLoginCubit, SocialLoginState>(
          builder: (context, socialSignUpState) {
            return BlocBuilder<SocialLoginCubit, SocialLoginState>(
              builder: (context, socialSignInState) {
                final (isLoading, title) = signInWithGoogleState.maybeWhen(
                  loading: () => (true, context.l10n.authPleaseWait),
                  orElse: () => socialSignUpState.maybeWhen(
                    loading: () => (true, context.l10n.authPleaseWait),
                    orElse: () => socialSignInState.maybeWhen(
                      loading: () => (true, context.l10n.authPleaseWait),
                      orElse: () =>
                          (false, context.l10n.authContinueWithGoogle),
                    ),
                  ),
                );

                return PRFButton(
                  onPressed: () =>
                      context.read<GoogleSignInCubit>().signInwithGoogle(),
                  variant: PRFButtonVariant.google,
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
