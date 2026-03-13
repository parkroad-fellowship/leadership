import 'package:flutter/material.dart';
import 'package:prf_design/prf_design.dart';

class MissionConfirmationSheet extends StatelessWidget {
  const MissionConfirmationSheet({
    required this.message,
    required this.confirmLabel,
    this.destructive = false,
    super.key,
  });

  final String message;
  final String confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: PRFSpacingTokens.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.md),
            Expanded(
              child: destructive
                  ? FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      child: Text(confirmLabel),
                    )
                  : PRFPrimaryButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      title: confirmLabel,
                      disabled: false,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
