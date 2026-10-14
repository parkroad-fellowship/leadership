import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_detail_cubit.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class EditRequisitionViewHandset extends StatefulWidget {
  const EditRequisitionViewHandset({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  State<EditRequisitionViewHandset> createState() =>
      _EditRequisitionViewHandsetState();
}

class _EditRequisitionViewHandsetState
    extends State<EditRequisitionViewHandset> {
  final _remarksController = TextEditingController();
  final _requisitionDateController = TextEditingController();

  bool _isLoading = false;
  DateTime? requisitionDate;
  PRFRequisition? requisition;

  @override
  void initState() {
    super.initState();
    // Add listeners to update form validity
    _remarksController.addListener(() => setState(() {}));
    _requisitionDateController.addListener(() => setState(() {}));

    // Load the requisition data
    _loadRequisition();
  }

  void _populateForm(PRFRequisition requisition) {
    setState(() {
      this.requisition = requisition;
      requisitionDate = requisition.requisitionDate;
      _remarksController.text = requisition.remarks ?? '';
      _requisitionDateController.text = DateFormat.MMMMEEEEd().format(
        requisition.requisitionDate,
      );
    });
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _requisitionDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: requisitionSheetBackground(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: SingleChildScrollView(
          child:
              BlocListener<
                RequisitionDetailCubit,
                ResourceState<PRFRequisition>
              >(
                listener: (context, state) {
                  switch (state) {
                    case ResourceItemLoaded<PRFRequisition>(:final item):
                      if (_isLoading) {
                        setState(() => _isLoading = false);
                        PRFSnackbar.success(context, l10n.requisitionUpdated);
                        Gaimon.success();
                        Navigator.of(context).pop(true);
                      } else {
                        _populateForm(item);
                      }
                    case ResourceItemError<PRFRequisition>():
                      if (_isLoading) {
                        setState(() => _isLoading = false);
                        PRFSnackbar.error(
                          context,
                          l10n.requisitionActionUpdateFailed,
                          onRetry: _submitForm,
                        );
                        Gaimon.error();
                      }
                    default:
                      break;
                  }
                },
                child: Column(
                  children: [
                    const SizedBox(height: PRFSpacingTokens.lg),

                    requisitionActionHeader(
                      context,
                      icon: Icons.edit_outlined,
                      title: l10n.editRequisition,
                      subtitle: l10n.modifyRequisitionDetails,
                      background: theme.colorScheme.secondary,
                      foreground: theme.colorScheme.onSecondary,
                    ).entrance(context, slide: const Offset(0, -0.3)),

                    const SizedBox(height: PRFSpacingTokens.xxl),

                    BlocBuilder<
                      RequisitionDetailCubit,
                      ResourceState<PRFRequisition>
                    >(
                      builder: (context, state) {
                        return switch (state) {
                          ResourceItemLoading<PRFRequisition>() => const Center(
                            child: PRFCircularProgressIndicator(),
                          ),
                          ResourceItemLoaded<PRFRequisition>() =>
                            _buildFormCard(context),
                          ResourceItemError<PRFRequisition>(:final item)
                              when item != null || requisition != null =>
                            _buildFormCard(context),
                          ResourceItemError<PRFRequisition>() =>
                            PRFErrorView.inline(
                              title: l10n.requisitionDetailLoadErrorTitle,
                              message: l10n.requisitionDetailLoadErrorMessage,
                              retryLabel: l10n.tryAgain,
                              onRetry: _loadRequisition,
                            ),
                          _ => const SizedBox.shrink(),
                        };
                      },
                    ),

                    const SizedBox(height: PRFSpacingTokens.xxl),

                    PRFButton(
                      onPressed: _submitForm,
                      title: l10n.requisitionActionSaveChanges,
                      disabled: _isLoading || requisition == null,
                      isLoading: _isLoading,
                    ).entrance(
                      context,
                      delay: PRFMotionTokens.stagger5,
                      slide: const Offset(0, 0.3),
                    ),

                    const SizedBox(height: PRFSpacingTokens.xxxl),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final l10n = context.l10n;
    return requisitionFormCard(
      context,
      child: Column(
        children: [
          PRFFormSection(
            icon: Icons.schedule_outlined,
            title: l10n.requisitionDate,
            isRequired: true,
            child: Semantics(
              button: true,
              label: l10n.requisitionDate,
              value: _requisitionDateController.text,
              hint: l10n.requisitionActionSelectDate,
              excludeSemantics: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _selectRequisitionDate,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                  child: AbsorbPointer(
                    child: PRFTextField(
                      hintText: l10n.requisitionActionSelectDate,
                      controller: _requisitionDateController,
                      enabled: false,
                    ),
                  ),
                ),
              ),
            ),
          ).entrance(
            context,
            delay: PRFMotionTokens.stagger4,
            slide: const Offset(-0.2, 0),
          ),
          PRFFormSection(
            icon: Icons.notes_outlined,
            title: l10n.purpose,
            isRequired: true,
            child: PRFTextField(
              hintText: l10n.requisitionActionPurposeHint,
              controller: _remarksController,
              type: PRFTextFieldType.textArea,
              minLines: 3,
              maxLines: 6,
            ),
          ).entrance(
            context,
            delay: PRFMotionTokens.stagger5,
            slide: const Offset(-0.2, 0),
          ),
        ],
      ),
    );
  }

  void _loadRequisition() {
    context.read<RequisitionDetailCubit>().loadOne(
      id: widget.requisitionUlid,
      matchById: (item) => item.ulid == widget.requisitionUlid,
    );
  }

  Future<void> _submitForm() async {
    final l10n = context.l10n;

    if (_remarksController.text.trim().isEmpty) {
      PRFSnackbar.warning(context, l10n.enterPurpose);
      Gaimon.warning();
      return;
    }

    if (requisitionDate == null) {
      PRFSnackbar.warning(context, l10n.requisitionActionDateRequired);
      Gaimon.warning();
      return;
    }

    setState(() => _isLoading = true);

    await context.read<RequisitionDetailCubit>().update(
      id: widget.requisitionUlid,
      data: {
        'requisition_date': requisitionDate!.toIso8601String(),
        'remarks': _remarksController.text.trim(),
      },
    );
  }

  Future<void> _selectRequisitionDate() async {
    await DatePicker.showDatePicker(
      context,
      minTime: DateTime.now().subtract(const Duration(days: 7)),
      maxTime: DateTime.now().add(const Duration(days: 30)),
      theme: picker.DatePickerTheme(
        itemStyle: Theme.of(context).textTheme.headlineSmall!,
        doneStyle: Theme.of(context).textTheme.headlineSmall!,
        cancelStyle: Theme.of(context).textTheme.headlineSmall!,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      onConfirm: (date) {
        setState(() {
          requisitionDate = date;
        });
        _requisitionDateController.text = DateFormat.MMMMEEEEd().format(date);
      },
      currentTime: requisitionDate ?? DateTime.now(),
    );
  }
}
