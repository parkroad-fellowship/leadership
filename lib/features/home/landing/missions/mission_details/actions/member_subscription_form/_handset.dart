import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/landing/missions/mission_details/actions/_shared/mission_sheet_section.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription_dto.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:prf_design/prf_design.dart';

class MissionMemberSubscriptionFormSheet extends StatefulWidget {
  const MissionMemberSubscriptionFormSheet({
    required this.missionUlid,
    super.key,
  });

  final String missionUlid;

  @override
  State<MissionMemberSubscriptionFormSheet> createState() =>
      _MissionMemberSubscriptionFormSheetState();
}

class _MissionMemberSubscriptionFormSheetState
    extends State<MissionMemberSubscriptionFormSheet> {
  String? _selectedMemberUlid;
  String? _selectionError;

  bool _validateSelection() {
    if (_selectedMemberUlid != null && _selectedMemberUlid!.trim().isNotEmpty) {
      setState(() {
        _selectionError = null;
      });
      return true;
    }

    setState(() {
      _selectionError = 'Please select a member to continue';
    });
    return false;
  }

  void _submit() {
    if (!_validateSelection()) {
      return;
    }

    Navigator.of(context).pop(
      PRFMissionSubscriptionDTO(
        missionUlid: widget.missionUlid,
        memberUlid: _selectedMemberUlid!.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: PRFSpacingTokens.lg),
                  MissionSheetSection(
                    title: 'Subscription',
                    subtitle: 'Choose a member to add to this mission',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: PRFSpacingTokens.md,
                            ),
                            child: PRFCircularProgressIndicator(),
                          )
                        else
                          DropdownMenu<String>(
                            width: double.infinity,
                            initialSelection: _selectedMemberUlid,
                            enableFilter: true,
                            requestFocusOnTap: true,
                            label: const Text('Member *'),
                            hintText: 'Search member',
                            helperText: 'Only active members are shown',
                            errorText: _selectionError,
                            dropdownMenuEntries: members
                                .map(
                                  (member) => DropdownMenuEntry<String>(
                                    value: member.ulid,
                                    label: member.fullName,
                                  ),
                                )
                                .toList(),
                            onSelected: (value) {
                              setState(() {
                                _selectedMemberUlid = value;
                                _selectionError = null;
                              });
                            },
                          ),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: PRFSpacingTokens.sm,
                            ),
                            child: Text(
                              errorMessage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        if (!isLoading && members.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: PRFSpacingTokens.sm,
                            ),
                            child: Text(
                              'No members found. Refresh and try again.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PRFSpacingTokens.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: PRFPrimaryButton(
                      onPressed: _submit,
                      title: 'Subscribe Member',
                      disabled: isLoading,
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(height: PRFSpacingTokens.xxxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
