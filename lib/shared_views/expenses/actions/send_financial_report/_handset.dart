import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/shared_views/expenses/cubit/send_financial_report_cubit.dart';
import 'package:leadership/shared_widgets/_index.dart';

class SendFinancialReportViewHandset extends StatelessWidget {
  const SendFinancialReportViewHandset({
    required this.accountingEventUlid,
    super.key,
  });

  final String accountingEventUlid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SendFinancialReportCubit, SendFinancialReportState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Financial report sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          },
          error: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send report: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.email_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Send Financial Report',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will email a detailed financial report to all relevant '
              'parties.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Report Contents',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildReportItem(context, '• Complete expense breakdown'),
                  _buildReportItem(
                    context,
                    '• Current balance and allocations',
                  ),
                  _buildReportItem(context, '• Transaction history'),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: PRFPrimaryButton(
        onPressed: () => _showConfirmationDialog(context),
        title: 'Send Financial Report',
        disabled: isLoading,
        isLoading: isLoading,
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Send Report'),
        content: const Text(
          'Are you sure you want to send the financial report? '
          'This will email the report to all relevant members.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SendFinancialReportCubit>().sendReport(
                accountingEventUlid: accountingEventUlid,
              );
            },
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }
}
