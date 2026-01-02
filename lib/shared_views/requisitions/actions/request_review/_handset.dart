import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/shared_views/requisitions/cubit/request_review_cubit.dart';
import 'package:leadership/shared_widgets/_index.dart';

class RequestReviewViewHandset extends StatefulWidget {
  const RequestReviewViewHandset({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  State<RequestReviewViewHandset> createState() =>
      _RequestReviewViewHandsetState();
}

class _RequestReviewViewHandsetState extends State<RequestReviewViewHandset> {
  PRFMember? selectedApprover;
  bool _isLoading = false;

  String get requisitionUlid => widget.requisitionUlid;

  @override
  void initState() {
    context.read<GetMembersCubit>().getMembers(
      groups: [PRFLeadershipGroup.executiveCommittee],
    );
    super.initState();
  }

  // Add form validity check
  bool get _isFormValid {
    return selectedApprover != null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.requestReview,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.requestReviewDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildFormSection(
                icon: Icons.person_outline,
                title: l10n.selectApprover,
                isRequired: true,
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return BlocBuilder<GetMembersCubit, GetMembersState>(
                          builder: (context, state) {
                            return state.maybeWhen(
                              orElse: () => const SizedBox.shrink(),
                              loading: () => const Center(
                                child: LinearProgressIndicator(),
                              ),
                              loaded: (leaders) => LayoutBuilder(
                                builder: (context, constraints) {
                                  return DropdownMenu<PRFMember>(
                                    width: constraints.maxWidth,
                                    initialSelection: selectedApprover,
                                    hintText: l10n.selectApprover,
                                    dropdownMenuEntries: leaders
                                        .map(
                                          (leader) =>
                                              DropdownMenuEntry<PRFMember>(
                                                value: leader,
                                                label: leader.fullName,
                                              ),
                                        )
                                        .toList(),
                                    onSelected: (member) => setState(() {
                                      selectedApprover = member;
                                    }),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit Button
            BlocConsumer<RequestReviewCubit, RequestReviewState>(
              listener: (context, state) {
                state.mapOrNull(
                  loading: (_) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  loaded: (_) {
                    setState(() {
                      _isLoading = false;
                    });
                    Gaimon.success();
                    context.read<GetRequisitionCubit>().getRequisition(
                      requisitionUlid: requisitionUlid,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.activityCreated)),
                    );
                  },
                  error: (error) {
                    setState(() {
                      _isLoading = false;
                    });
                    Gaimon.error();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.message)));
                  },
                );
              },
              builder: (context, state) {
                return PRFPrimaryButton(
                  onPressed: _submitForm,
                  title: l10n.record,
                  disabled: !_isFormValid,
                  isLoading: _isLoading,
                );
              },
            ).animate(delay: 700.ms).slideY(begin: 0.3).fadeIn(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required IconData icon,
    required String title,
    required Widget child,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              FormFieldLabel(label: title, isRequired: isRequired),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    final l10n = context.l10n;

    if (selectedApprover == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectApprover)),
      );
      Gaimon.warning();
      return;
    }

    await context.read<RequestReviewCubit>().requestReview(
      ulid: requisitionUlid,
      approverUlid: selectedApprover!.ulid,
    );
  }
}
