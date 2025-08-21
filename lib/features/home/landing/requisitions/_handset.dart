import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/widgets/timeline_requisitions_card.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_widgets/empty_state.dart';
import 'package:leadership/utils/router/router.gr.dart';

class RequisitionsViewHandset extends StatefulWidget {
  const RequisitionsViewHandset({required this.accountingEventUlid, super.key});

  final String accountingEventUlid;

  @override
  State<RequisitionsViewHandset> createState() =>
      _RequisitionsViewHandsetState();
}

class _RequisitionsViewHandsetState extends State<RequisitionsViewHandset> {
  @override
  void initState() {
    super.initState();
    context.read<GetRequisitionsCubit>().getRequisitions(
      accountingEventUlid: widget.accountingEventUlid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<GetRequisitionsCubit, GetRequisitionsState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          empty: () => RefreshIndicator(
            onRefresh: () =>
                context.read<GetRequisitionsCubit>().getRequisitions(
                  accountingEventUlid: widget.accountingEventUlid,
                ),
            child: PRFEmptyView(
              label: l10n.requisitions,
              description: 'No requisitions found for this activity',
              icon: Icons.receipt_outlined,
            ),
          ),
          loaded: (requisitions) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<GetRequisitionsCubit>().getRequisitions(
                    accountingEventUlid: widget.accountingEventUlid,
                  ),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: sortedRequisitions.length,
                itemBuilder: (context, index) {
                  final requisition = sortedRequisitions[index];
                  final isLast = index == sortedRequisitions.length - 1;

                  return TimelineRequisitionCard(
                        requisition: requisition,
                        isLast: isLast,
                        index: index,
                        onTap: () => context.router
                            .push(
                              RequisitionRoute(
                                requisitionUlid: requisition.ulid,
                              ),
                            )
                            .then((_) {
                              // ignore: use_build_context_synchronously
                              context
                                  .read<GetRequisitionsCubit>()
                                  .getRequisitions(
                                    accountingEventUlid:
                                        widget.accountingEventUlid,
                                  );
                            }),
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: 600.ms,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      );
                },
              ),
            );
          },
        );
      },
    );
  }
}
