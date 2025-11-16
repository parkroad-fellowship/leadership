import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/cubit/recall_requisition_cubit.dart';
import 'package:leadership/shared_widgets/_index.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orange.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 8),
                    Text(
                      'Recall Requisition',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Withdraw this requisition from the approval process',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Info Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Once recalled, you can recreate this requisition for '
                        'approval later.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).slideX(begin: -0.2).fadeIn(),

              const SizedBox(height: 24),

              // Notes Section (Optional)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
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
                child: _buildFormSection(
                  icon: Icons.notes_outlined,
                  title: 'Recall Notes',
                  subtitle: 'Optional reason for recalling',
                  child: PRFTextAreaInput(
                    controller: _notesController,
                    hintText:
                        'Enter your reason for recalling this requisition...',
                    maxLines: 4,
                  ),
                ).animate(delay: 400.ms).slideX(begin: -0.2).fadeIn(),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              BlocListener<RecallRequisitionCubit, RecallRequisitionState>(
                listener: (context, state) {
                  state.maybeWhen(
                    loading: () {
                      setState(() {
                        _isLoading = true;
                      });
                    },
                    loaded: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Requisition recalled successfully',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    error: (message) {
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                    orElse: () {},
                  );
                },
                child: Column(
                  children: [
                    // Recall Button
                    BlocBuilder<RecallRequisitionCubit, RecallRequisitionState>(
                      builder: (context, state) {
                        return PRFDestroyButton(
                          onPressed: _recallRequisition,
                          title: 'Recall Requisition',
                          disabled: !_canRecall,
                          isLoading: _isLoading,
                        ).animate(delay: 600.ms).slideY(begin: 0.3).fadeIn();
                      },
                    ),

                    const SizedBox(height: 12),

                    // Cancel Button
                    PRFSecondaryButton(
                      onPressed: () => Navigator.of(context).pop(),
                      title: 'Cancel',
                      disabled: _isLoading,
                    ).animate(delay: 700.ms).slideY(begin: 0.3).fadeIn(),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Future<void> _recallRequisition() async {
    await context.read<RecallRequisitionCubit>().recallRequisition(
      ulid: widget.requisitionUlid,
      approvalNotes: _notesController.text.trim().isEmpty
          ? 'Requisition recalled by the requisitor'
          : _notesController.text.trim(),
    );

    // Refresh the requisition data
    if (mounted) {
      await context.read<GetRequisitionCubit>().getRequisition(
        requisitionUlid: widget.requisitionUlid,
      );
    }
  }
}
