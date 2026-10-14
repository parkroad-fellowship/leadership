import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/features/members/cubit/member_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_detail_cubit.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
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
    _loadApprovers();
    super.initState();
  }

  void _loadApprovers() {
    context.read<MemberResourceCubit>().getMembers(
      groups: [PRFLeadershipGroup.executiveCommittee],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: requisitionSheetBackground(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: Column(
          children: [
            const SizedBox(height: PRFSpacingTokens.lg),

            requisitionActionHeader(
              context,
              icon: Icons.send_outlined,
              title: l10n.requestReview,
              subtitle: l10n.requisitionActionRequestReviewSubtitle,
            ).entrance(context, slide: const Offset(0, -0.3)),

            const SizedBox(height: PRFSpacingTokens.xxl),

            requisitionFormCard(
              context,
              child: PRFFormSection(
                icon: Icons.person_outline,
                title: l10n.selectApprover,
                isRequired: true,
                child:
                    BlocBuilder<MemberResourceCubit, ResourceState<PRFMember>>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          orElse: () => const SizedBox.shrink(),
                          listLoading: (items) =>
                              const PRFLinearProgressIndicator(),
                          error: (_, _) => PRFErrorView.inline(
                            title: l10n.requisitionActionApproversLoadFailed,
                            message: l10n.requisitionDetailLoadErrorMessage,
                            retryLabel: l10n.tryAgain,
                            onRetry: _loadApprovers,
                          ),
                          listLoaded: (leaders, _, _) =>
                              PRFSearchableList<PRFMember>(
                                entries: leaders
                                    .map(
                                      (leader) =>
                                          PRFSearchableListEntry<PRFMember>(
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
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.xxl),
            BlocConsumer<RequisitionDetailCubit, ResourceState<PRFRequisition>>(
              listener: (context, state) {
                switch (state) {
                  case ResourceItemLoading<PRFRequisition>():
                    setState(() => _isLoading = true);
                  case ResourceItemLoaded<PRFRequisition>():
                    setState(() => _isLoading = false);
                    Gaimon.success();
                    Navigator.of(context).pop();
                    PRFSnackbar.success(
                      context,
                      l10n.requisitionActionReviewRequested(
                        selectedApprover?.fullName ?? '',
                      ),
                    );
                  case ResourceItemError<PRFRequisition>():
                    setState(() => _isLoading = false);
                    Gaimon.error();
                    PRFSnackbar.error(
                      context,
                      l10n.requisitionActionReviewRequestFailed,
                      onRetry: _submitForm,
                    );
                  default:
                    break;
                }
              },
              builder: (context, state) {
                return PRFButton(
                  onPressed: _submitForm,
                  title: l10n.requisitionActionSendForReview,
                  disabled: _isLoading,
                  isLoading: _isLoading,
                );
              },
            ).entrance(
              context,
              delay: PRFMotionTokens.stagger5,
              slide: const Offset(0, 0.3),
            ),

            const SizedBox(height: PRFSpacingTokens.xxxl),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final l10n = context.l10n;

    if (selectedApprover == null) {
      PRFSnackbar.warning(context, l10n.selectApprover);
      Gaimon.warning();
      return;
    }

    await context.read<RequisitionDetailCubit>().requestReview(
      requisitionUlid: requisitionUlid,
      approverUlid: selectedApprover!.ulid,
    );
  }
}
