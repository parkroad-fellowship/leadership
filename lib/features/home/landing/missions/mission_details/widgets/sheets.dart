import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:prf_design/prf_design.dart';

class MissionConfirmationSheet extends StatelessWidget {
  const MissionConfirmationSheet({
    required this.message,
    required this.confirmLabel,
    this.destructive = false,
    super.key,
  });

  final String message;
  final String confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        const SizedBox(height: PRFSpacingTokens.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.md),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      )
                    : null,
                child: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MissionMemberSubscriptionFormSheet extends StatefulWidget {
  const MissionMemberSubscriptionFormSheet({super.key});

  @override
  State<MissionMemberSubscriptionFormSheet> createState() =>
      _MissionMemberSubscriptionFormSheetState();
}

class _MissionMemberSubscriptionFormSheetState
    extends State<MissionMemberSubscriptionFormSheet> {
  String? _selectedMemberUlid;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMembersCubit, GetMembersState>(
      builder: (context, state) {
        final members = state.maybeWhen(
          loaded: (members) => members,
          orElse: () => <PRFMember>[],
        );
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final errorMessage = state.maybeWhen(
          error: (message) => message,
          orElse: () => null,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MissionSheetSection(
              title: 'Subscription',
              subtitle: 'Choose a member to add to this mission',
              child: SizedBox.shrink(),
            ),
            const SizedBox(height: PRFSpacingTokens.sm),
            _MissionSheetSection(
              title: 'Member',
              subtitle: 'Only active members are shown',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PRFFormFieldLabel(label: 'Member', isRequired: true),
                  const SizedBox(height: PRFSpacingTokens.xs),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: PRFSpacingTokens.md,
                      ),
                      child: PRFCircularProgressIndicator(),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMemberUlid,
                      decoration: const InputDecoration(
                        hintText: 'Select a member',
                        helperText: 'Only active members are shown',
                      ),
                      items: members
                          .map<DropdownMenuItem<String>>(
                            (member) => DropdownMenuItem<String>(
                              value: member.ulid,
                              child: Text(member.fullName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMemberUlid = value;
                        });
                      },
                    ),
                  const SizedBox(height: PRFSpacingTokens.md),
                  if (errorMessage != null)
                    Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (!isLoading && members.isEmpty)
                    Text(
                      'No members found. Refresh and try again.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedMemberUlid == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedMemberUlid),
                child: const Text('Subscribe'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MissionSimpleTextFormSheet extends StatefulWidget {
  const MissionSimpleTextFormSheet({
    required this.label,
    required this.hintText,
    required this.submitLabel,
    this.maxLines = 4,
    this.isRequired = true,
    this.initialValue,
    super.key,
  });

  final String label;
  final String hintText;
  final String submitLabel;
  final int maxLines;
  final bool isRequired;
  final String? initialValue;

  @override
  State<MissionSimpleTextFormSheet> createState() =>
      _MissionSimpleTextFormSheetState();
}

class _MissionSimpleTextFormSheetState
    extends State<MissionSimpleTextFormSheet> {
  late final TextEditingController _controller;

  bool get _canSubmit {
    if (!widget.isRequired) {
      return true;
    }

    return _controller.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '')
      ..addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MissionSheetSection(
          title: widget.label,
          subtitle: widget.isRequired
              ? 'This field is required'
              : 'This field is optional',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFFormFieldLabel(
                label: widget.label,
                isRequired: widget.isRequired,
              ),
              if (widget.maxLines > 1)
                PRFTextAreaInput(
                  hintText: widget.hintText,
                  controller: _controller,
                )
              else
                PRFTextInput(
                  hintText: widget.hintText,
                  controller: _controller,
                ),
            ],
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _canSubmit
                ? () => Navigator.of(context).pop(_controller.text.trim())
                : null,
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}

class MissionSoulFormSheet extends StatefulWidget {
  const MissionSoulFormSheet({
    required this.submitLabel,
    this.initialName,
    this.initialNote,
    super.key,
  });

  final String submitLabel;
  final String? initialName;
  final String? initialNote;

  @override
  State<MissionSoulFormSheet> createState() => _MissionSoulFormSheetState();
}

class _MissionSoulFormSheetState extends State<MissionSoulFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;

  bool get _canSubmit => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '')
      ..addListener(_onChanged);
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _nameController
      ..removeListener(_onChanged)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MissionSheetSection(
          title: 'Soul Record',
          subtitle: 'Capture a decision and follow-up note',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PRFFormFieldLabel(
                label: 'Name / Identifier',
                isRequired: true,
              ),
              PRFTextInput(
                hintText: 'Enter a name or identifier',
                controller: _nameController,
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              const PRFFormFieldLabel(label: 'Decision Note'),
              PRFTextAreaInput(
                hintText: 'Optional details for follow-up',
                controller: _noteController,
              ),
            ],
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _canSubmit
                ? () => Navigator.of(context).pop((
                    name: _nameController.text.trim(),
                    note: _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim(),
                  ))
                : null,
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}

class MissionSubscriberDetailsSheet extends StatelessWidget {
  const MissionSubscriberDetailsSheet({
    required this.subscription,
    super.key,
  });

  final PRFMissionSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final member = subscription.member;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MissionSheetSection(
          title: 'Subscriber',
          subtitle: 'Fellowship member profile for this mission subscription',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Name', member!.fullName),
              _detailRow('Member ULID', member.ulid),
              ...[
                _detailRow('Email', member.email),
                _detailRow('Phone', member.phoneNumber),
                _detailRow('Residence', member.residence),
                _detailRow('Pastor', member.pastor),
              ],
            ],
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String? value) {
    final safeValue = (value ?? '').trim();
    if (safeValue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(safeValue),
        ],
      ),
    );
  }
}

class _MissionSheetSection extends StatelessWidget {
  const _MissionSheetSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          child,
        ],
      ),
    );
  }
}
