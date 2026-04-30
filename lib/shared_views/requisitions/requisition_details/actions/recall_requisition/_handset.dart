import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_resource_cubit.dart';
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

  bool get _canRecall => !_isLoading;

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
            Colors.orange.withValues(alpha: 0.05),
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
                          Colors.orange,
                          Colors.orange.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.undo_outlined,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          'Recall Requisition',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          'Withdraw this requisition from the approval process',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
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

              // Info Section
              Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: PRFSpacingTokens.md),
                        Expanded(
                          child: Text(
                            'Once recalled, you can recreate '
                            'this requisition for '
                            'approval later.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.orange.withValues(alpha: 0.9),
                                ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(delay: PRFMotionTokens.stagger2)
                  .slideX(begin: -0.2)
                  .fadeIn(),

              const SizedBox(height: PRFSpacingTokens.xxl),

              // Notes Section (Optional)
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
                          title: 'Recall Notes',
                          child: PRFTextAreaInput(
                            controller: _notesController,
                            hintText:
                                'Enter your reason for recalling '
                                'this requisition...',
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
                        Navigator.of(context).pop();
                        PRFSnackbar.success(
                          context,
                          'Requisition recalled successfully',
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
                    // Recall Button
                    PRFDestroyButton(
                          onPressed: _recallRequisition,
                          title: 'Recall Requisition',
                          disabled: !_canRecall,
                          isLoading: _isLoading,
                        )
                        .animate(delay: PRFMotionTokens.enterShort)
                        .slideY(begin: 0.3)
                        .fadeIn(),

                    const SizedBox(height: PRFSpacingTokens.md),

                    // Cancel Button
                    PRFSecondaryButton(
                          onPressed: () => Navigator.of(context).pop(),
                          title: 'Cancel',
                          disabled: _isLoading,
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

  Future<void> _recallRequisition() async {
    await context.read<RequisitionResourceCubit>().recallRequisition(
      requisitionUlid: widget.requisitionUlid,
      approvalNotes: _notesController.text.trim().isEmpty
          ? 'Requisition recalled by the requisitor'
          : _notesController.text.trim(),
    );
  }
}
