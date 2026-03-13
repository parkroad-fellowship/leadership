import 'package:flutter/material.dart';
import 'package:leadership/enums/prf_soul_decision_type.dart';
import 'package:leadership/features/home/landing/missions/mission_details/actions/_shared/mission_sheet_section.dart';
import 'package:leadership/models/remote/mission/prf_soul_dto.dart';
import 'package:leadership/models/remote/prf_class_group.dart';
import 'package:prf_design/prf_design.dart';

class MissionSoulFormSheet extends StatefulWidget {
  const MissionSoulFormSheet({
    required this.missionUlid,
    required this.classGroups,
    required this.submitLabel,
    this.initialName,
    this.initialNote,
    this.initialClassGroupUlid,
    this.initialDecisionType = PRFSoulDecisionType.salvation,
    super.key,
  });

  final String missionUlid;
  final List<PRFClassGroup> classGroups;
  final String submitLabel;
  final String? initialName;
  final String? initialNote;
  final String? initialClassGroupUlid;
  final PRFSoulDecisionType initialDecisionType;

  @override
  State<MissionSoulFormSheet> createState() => _MissionSoulFormSheetState();
}

class _MissionSoulFormSheetState extends State<MissionSoulFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  String? _selectedClassGroupUlid;
  late PRFSoulDecisionType _selectedDecisionType;
  String? _nameError;
  String? _classGroupError;
  bool _showValidation = false;

  bool _validate() {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasClassGroup =
        _selectedClassGroupUlid != null && _selectedClassGroupUlid!.isNotEmpty;

    setState(() {
      _showValidation = true;
      _nameError = hasName ? null : 'Name / Identifier is required';
      _classGroupError = hasClassGroup ? null : 'Class group is required';
    });

    return hasName && hasClassGroup;
  }

  void _submit() {
    if (!_validate()) {
      PRFSnackbar.error(context, 'Please fill in all required fields');
      return;
    }

    Navigator.of(context).pop(
      PRFSoulDTO(
        fullName: _nameController.text.trim(),
        missionUlid: widget.missionUlid,
        classGroupUlid: _selectedClassGroupUlid!,
        decisionType: _selectedDecisionType.apiKey,
        notes: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '')
      ..addListener(_onChanged);
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _selectedClassGroupUlid = widget.initialClassGroupUlid;
    _selectedDecisionType = widget.initialDecisionType;
  }

  void _onChanged() {
    if (_showValidation) {
      _validate();
      return;
    }
    setState(() {});
  }

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: PRFSpacingTokens.lg),
              MissionSheetSection(
                title: 'Soul Record',
                subtitle: 'Capture a decision and follow-up note',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PRFTextInput(
                      hintText: 'Enter a name or identifier',
                      labelText: 'Name / Identifier',
                      helperText: 'Required',
                      errorText: _showValidation ? _nameError : null,
                      controller: _nameController,
                    ),
                    const SizedBox(height: PRFSpacingTokens.md),
                    DropdownMenu<String>(
                      width: double.infinity,
                      initialSelection: _selectedClassGroupUlid,
                      enabled: widget.classGroups.isNotEmpty,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      label: const Text('Class Group *'),
                      hintText: 'Search class group',
                      helperText: widget.classGroups.isEmpty
                          ? 'No class groups found from mission sessions'
                          : 'Required',
                      errorText: _showValidation ? _classGroupError : null,
                      dropdownMenuEntries: widget.classGroups
                          .map(
                            (group) => DropdownMenuEntry<String>(
                              value: group.ulid,
                              label: group.name,
                            ),
                          )
                          .toList(),
                      onSelected: (value) {
                        setState(() {
                          _selectedClassGroupUlid = value;
                          _classGroupError = null;
                        });
                      },
                    ),
                    const SizedBox(height: PRFSpacingTokens.md),
                    PRFCategoryChips<PRFSoulDecisionType>(
                      categories: PRFSoulDecisionType.values,
                      labelBuilder: (value) => value.name,
                      selectedCategory: _selectedDecisionType,
                      showAllOption: false,
                      onCategorySelected: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedDecisionType = value;
                        });
                      },
                    ),
                    const SizedBox(height: PRFSpacingTokens.md),
                    PRFTextAreaInput(
                      hintText: 'Optional details for follow-up',
                      labelText: 'Notes',
                      helperText: 'Optional',
                      controller: _noteController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.xxl),
              SizedBox(
                width: double.infinity,
                child: PRFPrimaryButton(
                  onPressed: _submit,
                  title: widget.submitLabel,
                  disabled: false,
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
