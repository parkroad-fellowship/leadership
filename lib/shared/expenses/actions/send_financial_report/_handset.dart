import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/shared/expenses/cubit/send_financial_report_cubit.dart';
import 'package:prf_design/prf_design.dart';

class SendFinancialReportViewHandset extends StatelessWidget {
  const SendFinancialReportViewHandset({
    required this.accountingEventUlid,
    super.key,
  });

  final String accountingEventUlid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocListener<SendFinancialReportCubit, SendFinancialReportState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: () {
            PRFSnackbar.success(context, l10n.expenseReportSent);
            Navigator.of(context).pop();
          },
          error: (error) {
            PRFSnackbar.error(
              context,
              l10n.expenseReportSendFailed,
              onRetry: () => context
                  .read<SendFinancialReportCubit>()
                  .sendReport(accountingEventUlid: accountingEventUlid),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.email_outlined,
              size: PRFSizeTokens.iconXxxl,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: PRFSpacingTokens.lg),
            Text(
              l10n.expenseSendReportTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.sm),
            Text(
              l10n.expenseSendReportDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.xxl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(PRFSpacingTokens.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: PRFOpacities.glow,
                ),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(
                    alpha: PRFOpacities.glow,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: PRFSizeTokens.iconMd,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: PRFSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.expenseReportContents,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PRFSpacingTokens.sm),
                  _buildReportItem(context, l10n.expenseReportItemBreakdown),
                  _buildReportItem(context, l10n.expenseReportItemBalance),
                  _buildReportItem(context, l10n.expenseReportItemHistory),
                ],
              ),
            ),
            const Spacer(),
            BlocBuilder<SendFinancialReportCubit, SendFinancialReportState>(
              builder: (context, state) {
                return state.when(
                  initial: () => _buildSendButton(context, false),
                  loading: () => _buildSendButton(context, true),
                  loaded: () => _buildSendButton(context, false),
                  error: (_) => _buildSendButton(context, false),
                );
              },
            ),
            const SizedBox(height: PRFSpacingTokens.lg),
            PRFButton(
              onPressed: () => Navigator.of(context).pop(),
              title: l10n.cancel,
              variant: PRFButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PRFSpacingTokens.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check,
            size: PRFSizeTokens.iconSm,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, bool isLoading) {
    return PRFButton(
      onPressed: () => _showConfirmationDialog(context),
      title: context.l10n.expenseSendReportButton,
      disabled: isLoading,
      isLoading: isLoading,
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: l10n.expenseSendReportConfirmTitle,
      message: l10n.expenseSendReportConfirmMessage,
      confirmLabel: l10n.expenseSendReportButton,
      cancelLabel: l10n.cancel,
    );

    if ((confirmed ?? false) && context.mounted) {
      await context.read<SendFinancialReportCubit>().sendReport(
        accountingEventUlid: accountingEventUlid,
      );
    }
  }
}
