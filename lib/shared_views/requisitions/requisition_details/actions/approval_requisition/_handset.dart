import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class ApproveRequisitionViewHandset extends StatefulWidget {
  const ApproveRequisitionViewHandset({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  State<ApproveRequisitionViewHandset> createState() =>
      _ApproveRequisitionViewHandsetState();
}

class _ApproveRequisitionViewHandsetState
    extends State<ApproveRequisitionViewHandset> {
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isRejecting = false;

  // Rejection requires notes, approval does not
  bool get _canApprove => !_isLoading;
  bool get _canReject => !_isLoading && _notesController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _notesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: SingleChildScrollView(
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
                          Icons.fact_check_outlined,
                          size: 32,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          'Review Requisition',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          'Approve or reject this requisition request',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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

              // Notes Section
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
                child:
                    PRFFormSection(
                          icon: Icons.notes_outlined,
                          title: 'Approval Notes',
                          child: PRFTextAreaInput(
                            controller: _notesController,
                            hintText:
                                'Enter your notes or reason for rejection...',
                            maxLines: 4,
                          ),
                        )
                        .animate(delay: PRFMotionTokens.stagger4)
                        .slideX(begin: -0.2)
                        .fadeIn(),
              ),

              const SizedBox(height: PRFSpacingTokens.xxl),

              // Action Buttons
              BlocListener<
                RequisitionResourceCubit,
                ResourceState<PRFRequisition>
              >(
                listener: (context, state) {
                  switch (state) {
                    case ResourceMutating<PRFRequisition>(:final operation):
                      if (operation == ResourceOperation.update) {
                        setState(() {
                          _isLoading = true;
                        });
                      }
                    case ResourceMutated<PRFRequisition>(:final operation):
                      if (operation == ResourceOperation.update) {
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
                        PRFSnackbar.success(
                          context,
                          _isRejecting
                              ? 'Requisition rejected successfully'
                              : 'Requisition approved successfully',
                        );
                      }
                    case ResourceError<PRFRequisition>(:final message):
                      setState(() {
                        _isLoading = false;
                      });
                      PRFSnackbar.error(context, message);
                    default:
                      break;
                  }
                },
                child: Column(
                  children: [
                    // Approve Button
                    PRFPrimaryButton(
                          onPressed: _approveRequisition,
                          title: 'Approve Requisition',
                          disabled: !_canApprove,
                          isLoading: _isLoading && !_isRejecting,
                        )
                        .animate(delay: PRFMotionTokens.enterShort)
                        .slideY(begin: 0.3)
                        .fadeIn(),

                    const SizedBox(height: PRFSpacingTokens.md),

                    // Reject Button
                    PRFDestroyButton(
                          onPressed: _rejectRequisition,
                          title: 'Reject Requisition',
                          disabled: !_canReject,
                          isLoading: _isLoading && _isRejecting,
                        )
                        .animate(delay: PRFMotionTokens.enterMedium)
                        .slideY(begin: 0.3)
                        .fadeIn(),
                  ],
                ),
              ),

              const SizedBox(height: PRFSpacingTokens.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _approveRequisition() async {
    setState(() {
      _isRejecting = false;
    });

    await context.read<RequisitionResourceCubit>().approveRequisition(
      requisitionUlid: widget.requisitionUlid,
      approvalNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  Future<void> _rejectRequisition() async {
    final notes = _notesController.text.trim();

    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes are required when rejecting a requisition'),
        ),
      );
      Gaimon.warning();
      return;
    }

    setState(() {
      _isRejecting = true;
    });

    await context.read<RequisitionResourceCubit>().rejectRequisition(
      requisitionUlid: widget.requisitionUlid,
      approvalNotes: notes,
    );
  }
}
