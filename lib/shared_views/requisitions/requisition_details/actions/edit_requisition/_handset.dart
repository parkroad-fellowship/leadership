import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_resource_cubit.dart';
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

  // Add form validity check
  bool get _isFormValid {
    return _remarksController.text.isNotEmpty && requisitionDate != null;
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to update form validity
    _remarksController.addListener(() => setState(() {}));
    _requisitionDateController.addListener(() => setState(() {}));

    // Load the requisition data
    context.read<RequisitionResourceCubit>().loadRequisition(
      requisitionUlid: widget.requisitionUlid,
    );
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
          child:
              BlocListener<
                RequisitionResourceCubit,
                ResourceState<PRFRequisition>
              >(
                listener: (context, state) {
                  switch (state) {
                    case ResourceListLoaded<PRFRequisition>(:final items)
                        when items.isNotEmpty:
                      _populateForm(items.first);
                    case ResourceMutated<PRFRequisition>(:final items)
                        when items.isNotEmpty:
                      _populateForm(items.first);
                    case ResourceMutating<PRFRequisition>(:final operation)
                        when operation == ResourceOperation.update:
                      setState(() {
                        _isLoading = true;
                      });
                    case ResourceMutated<PRFRequisition>(:final operation)
                        when operation == ResourceOperation.update:
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.requisitionUpdated)),
                      );
                      Gaimon.success();
                      Navigator.of(context).pop(true);
                    case ResourceError<PRFRequisition>(:final message)
                        when _isLoading:
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $message')),
                      );
                      Gaimon.error();
                    default:
                      break;
                  }
                },
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
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.lg,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 32,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                              const SizedBox(height: PRFSpacingTokens.sm),
                              Text(
                                l10n.editRequisition,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: PRFSpacingTokens.xs),
                              Text(
                                l10n.modifyRequisitionDetails,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary.withValues(
                                            alpha: 0.9,
                                          ),
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

                    // Form Card
                    BlocBuilder<
                      RequisitionResourceCubit,
                      ResourceState<PRFRequisition>
                    >(
                      builder: (context, state) {
                        return switch (state) {
                          ResourceListLoading<PRFRequisition>() => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          ResourceListLoaded<PRFRequisition>(:final items)
                              when items.isNotEmpty =>
                            Container(
                              padding: const EdgeInsets.all(
                                PRFSpacingTokens.xl,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                  PRFRadiusTokens.lg,
                                ),
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
                                          child: AbsorbPointer(
                                            child: PRFTextInput(
                                              hintText: 'Select date',
                                              controller:
                                                  _requisitionDateController,
                                              enabled: false,
                                            ),
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
                                      .animate(
                                        delay: PRFMotionTokens.enterShort,
                                      )
                                      .slideX(begin: -0.2)
                                      .fadeIn(),
                                ],
                              ),
                            ),
                          ResourceError<PRFRequisition>(:final message) =>
                            Center(
                              child: Text(
                                'Error loading requisition: $message',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            ),
                          _ => const SizedBox.shrink(),
                        };
                      },
                    ),

                    const SizedBox(height: PRFSpacingTokens.xxl),

                    PRFPrimaryButton(
                          onPressed: _submitForm,
                          title: 'Update',
                          disabled: !_isFormValid,
                          isLoading: _isLoading,
                        )
                        .animate(delay: PRFMotionTokens.enterMedium)
                        .slideY(begin: 0.3)
                        .fadeIn(),

                    const SizedBox(height: PRFSpacingTokens.xxxl),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final l10n = context.l10n;

    if (_remarksController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterPurpose)),
      );
      Gaimon.warning();
      return;
    }

    if (requisitionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select requisition date')),
      );
      Gaimon.warning();
      return;
    }

    await context.read<RequisitionResourceCubit>().updateRequisition(
      accountingEvent: requisition!.accountingEvent!,
      requisitionUlid: widget.requisitionUlid,
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      onConfirm: (date) {
        setState(() {
          requisitionDate = date;
        });
        _requisitionDateController.text = DateFormat.MMMMEEEEd().format(
          date,
        );
      },
      currentTime: requisitionDate ?? DateTime.now(),
    );
  }
}
