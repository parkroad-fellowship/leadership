import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:prf_design/prf_design.dart';

/// Full-screen load error that keeps the branded header (title + back) and
/// offers a labelled "Try again" button wired to [onRetry].
///
/// Never pass raw exception text as [message]; it defaults to a plain
/// "check your connection" hint.
class PRFLeadershipErrorScreen extends StatelessWidget {
  const PRFLeadershipErrorScreen({
    required this.navBarTitle,
    required this.title,
    required this.onRetry,
    this.message,
    this.onBack,
    super.key,
  });

  /// Header title, usually the screen name.
  final String navBarTitle;

  /// What failed, e.g. "Couldn't load professions".
  final String title;

  /// Recovery hint. Defaults to the shared connection message.
  final String? message;

  /// Re-runs the failed load.
  final VoidCallback onRetry;

  /// Header back action. Defaults to popping the route.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        PRFBrandedNavBar(title: navBarTitle, onBack: onBack),
        Expanded(
          child: PRFErrorView.fromMessage(
            title: title,
            message: message ?? l10n.commonLoadErrorMessage,
            onRetry: onRetry,
            retryLabel: l10n.commonTryAgain,
          ),
        ),
      ],
    );
  }
}
