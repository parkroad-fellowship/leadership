import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_detail_cubit.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class RecallRequisitionViewHandset extends StatefulWidget {
  const RecallRequisitionViewHandset({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  State<RecallRequisitionViewHandset> createState() =>
      _RecallRequisitionViewHandsetState();
}

class _RecallRequisitionViewHandsetState
    extends State<RecallRequisitionViewHandset> {
  final _notesController = TextEditingController();
  bool _isLoading = false;

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
    final l10n = context.l10n;
    final warning = context.statusColors.warning;

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
                icon: Icons.undo_outlined,
                title: l10n.recallRequisition,
                subtitle: l10n.recallRequisitionDesc,
                background: warning.main,
                foreground: warning.onColor,
              ).entrance(context, slide: const Offset(0, -0.3)),

              const SizedBox(height: PRFSpacingTokens.xxl),

              requisitionStatusBanner(
                context,
                colors: warning,
                icon: Icons.info_outline,
                message: l10n.requisitionActionRecallInfo,
              ).entrance(
                context,
                delay: PRFMotionTokens.stagger2,
                slide: const Offset(-0.2, 0),
              ),

              const SizedBox(height: PRFSpacingTokens.xxl),

              requisitionFormCard(
                context,
                child: PRFFormSection(
                  icon: Icons.notes_outlined,
                  title: l10n.requisitionActionRecallNotesTitle,
                  child: PRFTextField(
                    controller: _notesController,
                    hintText: l10n.requisitionActionRecallNotesHint,
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
                      Navigator.of(context).pop();
                      PRFSnackbar.success(context, l10n.requisitionRecalled);
                    case ResourceItemError<PRFRequisition>():
                      setState(() => _isLoading = false);
                      PRFSnackbar.error(
                        context,
                        l10n.requisitionActionRecallFailed,
                        onRetry: _recallRequisition,
                      );
                    default:
                      break;
                  }
                },
                child: Column(
                  children: [
                    PRFButton(
                      onPressed: _confirmRecall,
                      title: l10n.recallRequisition,
                      variant: PRFButtonVariant.destructive,
                      disabled: _isLoading,
                      isLoading: _isLoading,
                    ).entrance(
                      context,
                      delay: PRFMotionTokens.stagger5,
                      slide: const Offset(0, 0.3),
                    ),

                    const SizedBox(height: PRFSpacingTokens.md),

                    PRFButton(
                      onPressed: () => Navigator.of(context).pop(),
                      title: l10n.cancel,
                      variant: PRFButtonVariant.secondary,
                      disabled: _isLoading,
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

  Future<void> _confirmRecall() async {
    final l10n = context.l10n;
    final requisition = context.read<RequisitionDetailCubit>().currentItem;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: requisition == null
          ? l10n.recallRequisition
          : l10n.requisitionActionRecallConfirmTitle(
              formatKes(requisition.totalAmount),
            ),
      message: l10n.confirmRecallRequisition,
      confirmLabel: l10n.recallRequisition,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );
    if (confirmed == true && mounted) await _recallRequisition();
  }

  Future<void> _recallRequisition() async {
    await context.read<RequisitionDetailCubit>().recallRequisition(
      requisitionUlid: widget.requisitionUlid,
      approvalNotes: _notesController.text.trim().isEmpty
          ? 'Requisition recalled by the requisitor'
          : _notesController.text.trim(),
    );
  }
}
