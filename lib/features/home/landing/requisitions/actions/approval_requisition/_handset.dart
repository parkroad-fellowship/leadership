import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/cubit/approve_requisition_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/cubit/reject_requisition_cubit.dart';
import 'package:leadership/shared_widgets/_index.dart';

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
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 8),
                    Text(
                      'Review Requisition',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Approve or reject this requisition request',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Notes Section
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
                  title: 'Approval Notes',
                  subtitle: 'Optional for approval, required for rejection',
                  child: PRFTextAreaInput(
                    controller: _notesController,
                    hintText: 'Enter your notes or reason for rejection...',
                    maxLines: 4,
                  ),
                ).animate(delay: 400.ms).slideX(begin: -0.2).fadeIn(),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              MultiBlocListener(
                listeners: [
                  BlocListener<ApproveRequisitionCubit, ApproveRequisitionState>(
                    listener: (context, state) {
                      state.mapOrNull(
                        loading: (_) {
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        loaded: (_) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Requisition approved successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        error: (error) {
                          setState(() {
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        },
                      );
                    },
                  ),
                  BlocListener<RejectRequisitionCubit, RejectRequisitionState>(
                    listener: (context, state) {
                      state.mapOrNull(
                        loading: (_) {
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        loaded: (_) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Requisition rejected successfully'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        error: (error) {
                          setState(() {
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        },
                      );
                    },
                  ),
                ],
                child: Column(
                  children: [
                    // Approve Button
                    PRFPrimaryButton(
                      onPressed: _approveRequisition,
                      title: 'Approve Requisition',
                      disabled: !_canApprove,
                      isLoading: _isLoading && !_isRejecting,
                    ).animate(delay: 600.ms).slideY(begin: 0.3).fadeIn(),

                    const SizedBox(height: 12),

                    // Reject Button
                    PRFDestroyButton(
                      onPressed: _rejectRequisition,
                      title: 'Reject Requisition',
                      disabled: !_canReject,
                      isLoading: _isLoading && _isRejecting,
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
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
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

  Future<void> _approveRequisition() async {
    setState(() {
      _isRejecting = false;
    });

    await context.read<ApproveRequisitionCubit>().approveRequisition(
      ulid: widget.requisitionUlid,
      approvalNotes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );

    // Refresh the requisition data
    if (mounted) {
      context.read<GetRequisitionCubit>().getRequisition(
        requisitionUlid: widget.requisitionUlid,
      );
    }
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

    await context.read<RejectRequisitionCubit>().rejectRequisition(
      ulid: widget.requisitionUlid,
      approvalNotes: notes,
    );

    // Refresh the requisition data
    if (mounted) {
      context.read<GetRequisitionCubit>().getRequisition(
        requisitionUlid: widget.requisitionUlid,
      );
    }
  }
}
