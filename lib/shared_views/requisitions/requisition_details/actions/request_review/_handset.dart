import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: Column(
          children: [
            const SizedBox(height: PRFSpacingTokens.lg),

            // Header Card
            Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
                      const SizedBox(height: PRFSpacingTokens.sm),
                      Text(
                        l10n.requestReview,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: PRFSpacingTokens.xs),
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
                )
                .animate()
                .slideY(begin: -0.3)
                .fadeIn(duration: PRFMotionTokens.enterShort),

            const SizedBox(height: PRFSpacingTokens.xxl),

            Container(
              padding: const EdgeInsets.all(PRFSpacingTokens.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
              child: PRFFormSection(
                icon: Icons.person_outline,
                title: l10n.selectApprover,
                isRequired: true,
                child: Column(
                  children: [
                    BlocBuilder<GetMembersCubit, GetMembersState>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          orElse: () => const SizedBox.shrink(),
                          loading: () => const Center(
                            child: LinearProgressIndicator(),
                          ),
                          loaded: (leaders) => PRFSearchableList<PRFMember>(
                            entries: leaders
                                .map(
                                  (leader) => PRFSearchableListEntry<PRFMember>(
                                    value: leader,
                                    label: leader.fullName,
                                  ),
                                )
                                .toList(),
                            onSelected: (member) => setState(() {
                              selectedApprover = member;
                            }),
                            selection: selectedApprover,
                            hintText: l10n.selectApprover,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.xxl),
            // Submit Button
            BlocConsumer<
                  RequisitionResourceCubit,
                  ResourceState<PRFRequisition>
                >(
                  listener: (context, state) {
                    switch (state) {
                      case ResourceMutating<PRFRequisition>(
                        :final operation,
                      ):
                        if (operation == ResourceOperation.update) {
                          setState(() {
                            _isLoading = true;
                          });
                        }
                      case ResourceMutated<PRFRequisition>(
                        :final operation,
                      ):
                        if (operation == ResourceOperation.update) {
                          setState(() {
                            _isLoading = false;
                          });
                          Gaimon.success();
                          Navigator.of(context).pop();
                          PRFSnackbar.success(context, l10n.activityCreated);
                        }
                      case ResourceError<PRFRequisition>(:final message):
                        setState(() {
                          _isLoading = false;
                        });
                        Gaimon.error();
                        PRFSnackbar.error(context, message);
                      default:
                        break;
                    }
                  },
                  builder: (context, state) {
                    return PRFPrimaryButton(
                      onPressed: _submitForm,
                      title: l10n.record,
                      disabled: !_isFormValid,
                      isLoading: _isLoading,
                    );
                  },
                )
                .animate(delay: PRFMotionTokens.enterMedium)
                .slideY(begin: 0.3)
                .fadeIn(),

            const SizedBox(height: PRFSpacingTokens.xxxl),
          ],
        ),
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

    await context.read<RequisitionResourceCubit>().requestReview(
      requisitionUlid: requisitionUlid,
      approverUlid: selectedApprover!.ulid,
    );
  }
}
