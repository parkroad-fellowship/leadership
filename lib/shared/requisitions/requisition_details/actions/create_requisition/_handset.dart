import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setDefaultPurpose();
    _remarksController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _setDefaultPurpose() {
    setState(() {
      _remarksController.text = widget.accountingEvent.name.split(': ').last;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: requisitionSheetBackground(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const SizedBox(height: PRFSpacingTokens.lg),
              requisitionActionHeader(
                context,
                icon: Icons.add_circle_outline,
                title: l10n.createNewRequisition,
              ).entrance(context, slide: const Offset(0, -0.3)),
              const SizedBox(height: PRFSpacingTokens.xxl),
              requisitionFormCard(
                context,
                child: PRFFormSection(
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
                ),
              ).entrance(
                context,
                delay: PRFMotionTokens.stagger4,
                slide: const Offset(-0.2, 0),
              ),
              const SizedBox(height: PRFSpacingTokens.xxl),
              BlocConsumer<
                    RequisitionResourceCubit,
                    ResourceState<PRFRequisition>
                  >(
                    listener: (context, state) {
                      switch (state) {
                        case ResourceMutating<PRFRequisition>(:final operation):
                          if (operation == ResourceOperation.create) {
                            setState(() => _isLoading = true);
                          }
                        case ResourceListLoaded<PRFRequisition>():
                          setState(() => _isLoading = false);
                          Gaimon.success();
                          Navigator.of(context).pop();
                          PRFSnackbar.success(
                            context,
                            l10n.requisitionActionCreated,
                          );
                        case ResourceError<PRFRequisition>():
                          setState(() => _isLoading = false);
                          Gaimon.error();
                          PRFSnackbar.error(
                            context,
                            l10n.requisitionActionCreateFailed,
                            onRetry: _submitForm,
                          );
                        default:
                          break;
                      }
                    },
                    builder: (context, state) {
                      return PRFButton(
                        onPressed: _submitForm,
                        title: l10n.createRequisition,
                        disabled: _isLoading,
                        isLoading: _isLoading,
                      );
                    },
                  )
                  .entrance(
                    context,
                    delay: PRFMotionTokens.stagger5,
                    slide: const Offset(0, 0.3),
                  ),
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
      PRFSnackbar.warning(context, l10n.enterPurpose);
      Gaimon.warning();
      return;
    }

    await context.read<RequisitionResourceCubit>().createRequisition(
      accountingEvent: widget.accountingEvent,
      remarks: _remarksController.text.trim(),
    );
  }
}
