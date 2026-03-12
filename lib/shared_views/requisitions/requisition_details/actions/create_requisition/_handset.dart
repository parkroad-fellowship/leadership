import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class CreateRequisitionViewHandset extends StatefulWidget {
  const CreateRequisitionViewHandset({
    required this.accountingEvent,
    super.key,
  });

  final PRFAccountingEvent accountingEvent;

  @override
  State<CreateRequisitionViewHandset> createState() =>
      _CreateRequisitionViewHandsetState();
}

class _CreateRequisitionViewHandsetState
    extends State<CreateRequisitionViewHandset> {
  final _remarksController = TextEditingController();
  final _requisitionDateController = TextEditingController();

  bool _isLoading = false;
  DateTime? requisitionDate;

  bool get _isFormValid {
    return _remarksController.text.isNotEmpty && requisitionDate != null;
  }

  @override
  void initState() {
    super.initState();
    _setDefaultDate();
    _remarksController.addListener(() => setState(() {}));
    _requisitionDateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _requisitionDateController.dispose();
    super.dispose();
  }

  void _setDefaultDate() {
    final date = DateTime.now();
    setState(() {
      requisitionDate = date;
    });
    _requisitionDateController.text = DateFormat.MMMMEEEEd().format(date);
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const SizedBox(height: PRFSpacingTokens.lg),
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
                          'Create New Requisition',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          'Create a new requisition for the accounting event',
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
                child: Column(
                  children: [
                    PRFFormSection(
                          icon: Icons.schedule_outlined,
                          title: 'Requisition Date',
                          isRequired: true,
                          child: GestureDetector(
                            onTap: _selectRequisitionDate,
                            child: PRFTextInput(
                              hintText: 'Requisition Date',
                              controller: _requisitionDateController,
                              enabled: false,
                            ),
                          ),
                        )
                        .animate(delay: PRFMotionTokens.stagger4)
                        .slideX(begin: -0.2)
                        .fadeIn(),
                    PRFFormSection(
                          icon: Icons.notes_outlined,
                          title: l10n.purpose,
                          isRequired: true,
                          child: PRFTextAreaInput(
                            hintText: l10n.purpose,
                            controller: _remarksController,
                          ),
                        )
                        .animate(delay: PRFMotionTokens.enterShort)
                        .slideX(begin: -0.2)
                        .fadeIn(),
                  ],
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.xxl),
              BlocConsumer<
                    RequisitionResourceCubit,
                    ResourceState<PRFRequisition>
                  >(
                    listener: (context, state) {
                      switch (state) {
                        case ResourceMutating<PRFRequisition>(
                          :final operation,
                        ):
                          if (operation == ResourceOperation.create) {
                            setState(() => _isLoading = true);
                          }
                        case ResourceMutated<PRFRequisition>(
                          :final operation,
                        ):
                          if (operation == ResourceOperation.create) {
                            setState(() => _isLoading = false);
                            Gaimon.success();
                            Navigator.of(context).pop();
                            PRFSnackbar.success(context, l10n.activityCreated);
                          }
                        case ResourceError<PRFRequisition>(:final message):
                          setState(() => _isLoading = false);
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
      ),
    );
  }

  Future<void> _submitForm() async {
    final l10n = context.l10n;

    if (_remarksController.text.trim().isEmpty) {
      PRFSnackbar.error(context, l10n.enterPurpose);
      Gaimon.warning();
      return;
    }

    if (requisitionDate == null) {
      PRFSnackbar.error(context, 'Please select requisition date');
      Gaimon.warning();
      return;
    }

    await context.read<RequisitionResourceCubit>().createRequisition(
      accountingEvent: widget.accountingEvent,
      requisitionDate: requisitionDate!,
      remarks: _remarksController.text.trim(),
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
      ),
      onConfirm: (date) {
        setState(() {
          requisitionDate = date;
        });
        _requisitionDateController.text = DateFormat.MMMMEEEEd().format(date);
      },
      currentTime: DateTime.now(),
    );
  }
}
