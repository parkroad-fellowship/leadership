import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_detail_cubit.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
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

  /// The requisition total, formatted, when the details are already loaded.
  String? get _amount {
    final requisition = context.read<RequisitionDetailCubit>().currentItem;
    return requisition == null ? null : formatKes(requisition.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final amount = _amount;

    return DecoratedBox(
      decoration: requisitionSheetBackground(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: PRFSpacingTokens.lg),

              requisitionActionHeader(
                context,
                icon: Icons.fact_check_outlined,
                title: l10n.requisitionActionReviewTitle,
                subtitle: l10n.requisitionActionReviewSubtitle,
                footer: amount == null
                    ? null
                    : Text(
                        l10n.requisitionActionTotalRequested(amount),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
              ).entrance(context, slide: const Offset(0, -0.3)),

              const SizedBox(height: PRFSpacingTokens.xxl),

              requisitionFormCard(
                context,
                child: PRFFormSection(
                  icon: Icons.notes_outlined,
                  title: l10n.approvalNotes,
                  child: PRFTextField(
                    controller: _notesController,
                    hintText: l10n.requisitionActionApprovalNotesHint,
                    minLines: 3,
                    maxLines: 6,
                    type: PRFTextFieldType.textArea,
                  ),
                ),
              ).entrance(
                context,
                delay: PRFMotionTokens.stagger4,
                slide: const Offset(-0.2, 0),
              ),

              const SizedBox(height: PRFSpacingTokens.xxl),

              BlocListener<
                RequisitionDetailCubit,
                ResourceState<PRFRequisition>
              >(
                listener: (context, state) {
                  switch (state) {
                    case ResourceItemLoading<PRFRequisition>():
                      setState(() => _isLoading = true);
                    case ResourceItemLoaded<PRFRequisition>():
                      setState(() => _isLoading = false);
                      Navigator.of(context).pop();
                      PRFSnackbar.success(
                        context,
                        _isRejecting
                            ? l10n.requisitionActionRejected
                            : l10n.requisitionActionApproved,
                      );
                    case ResourceItemError<PRFRequisition>():
                      setState(() => _isLoading = false);
                      PRFSnackbar.error(
                        context,
                        _isRejecting
                            ? l10n.requisitionActionRejectFailed
                            : l10n.requisitionActionApproveFailed,
                        onRetry: _isRejecting ? _reject : _approve,
                      );
                    default:
                      break;
                  }
                },
                child: Column(
                  children: [
                    PRFButton(
                      onPressed: _confirmApprove,
                      title: l10n.requisitionActionApproveButton,
                      disabled: _isLoading,
                      isLoading: _isLoading && !_isRejecting,
                    ).entrance(
                      context,
                      delay: PRFMotionTokens.stagger5,
                      slide: const Offset(0, 0.3),
                    ),

                    const SizedBox(height: PRFSpacingTokens.md),

                    PRFButton(
                      onPressed: _confirmReject,
                      title: l10n.requisitionActionRejectButton,
                      variant: PRFButtonVariant.destructive,
                      disabled: _isLoading,
                      isLoading: _isLoading && _isRejecting,
                    ).entrance(
                      context,
                      delay: PRFMotionTokens.stagger5,
                      slide: const Offset(0, 0.3),
                    ),
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

  Future<void> _confirmApprove() async {
    final l10n = context.l10n;
    final amount = _amount;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: amount == null
          ? l10n.requisitionActionApproveButton
          : l10n.requisitionActionApproveConfirmTitle(amount),
      message: l10n.requisitionActionApproveConfirmMessage,
      confirmLabel: l10n.requisitionActionApproveButton,
      cancelLabel: l10n.cancel,
    );
    if (confirmed == true && mounted) await _approve();
  }

  Future<void> _confirmReject() async {
    final l10n = context.l10n;
    if (_notesController.text.trim().isEmpty) {
      PRFSnackbar.warning(context, l10n.requisitionActionRejectNotesRequired);
      Gaimon.warning();
      return;
    }
    final amount = _amount;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: amount == null
          ? l10n.requisitionActionRejectButton
          : l10n.requisitionActionRejectConfirmTitle(amount),
      message: l10n.requisitionActionRejectConfirmMessage,
      confirmLabel: l10n.requisitionActionRejectButton,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );
    if (confirmed == true && mounted) await _reject();
  }

  Future<void> _approve() async {
    setState(() => _isRejecting = false);

    await context.read<RequisitionDetailCubit>().approveRequisition(
      requisitionUlid: widget.requisitionUlid,
      approvalNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
  }

  Future<void> _reject() async {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) return;

    setState(() => _isRejecting = true);

    await context.read<RequisitionDetailCubit>().rejectRequisition(
      requisitionUlid: widget.requisitionUlid,
      approvalNotes: notes,
    );
  }
}
