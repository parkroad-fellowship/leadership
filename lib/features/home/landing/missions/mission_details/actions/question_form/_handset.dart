import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/actions/_shared/mission_sheet_section.dart';
import 'package:prf_design/prf_design.dart';

class MissionQuestionFormSheet extends StatefulWidget {
  const MissionQuestionFormSheet({
    required this.submitLabel,
    this.initialValue,
    super.key,
  });

  final String submitLabel;
  final String? initialValue;

  @override
  State<MissionQuestionFormSheet> createState() =>
      _MissionQuestionFormSheetState();
}

class _MissionQuestionFormSheetState extends State<MissionQuestionFormSheet> {
  late final TextEditingController _controller;
  String? _error;
  bool _showValidation = false;

  bool _validate() {
    final isValid = _controller.text.trim().isNotEmpty;
    setState(() {
      _showValidation = true;
      _error = isValid ? null : 'Question is required';
    });
    return isValid;
  }

  void _submit() {
    if (!_validate()) {
      PRFSnackbar.error(context, 'Please fill in all required fields');
      return;
    }

    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '')
      ..addListener(_onChanged);
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
    _controller
      ..removeListener(_onChanged)
      ..dispose();
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
                title: 'Question',
                subtitle: 'Capture what students asked during the mission',
                child: PRFTextAreaInput(
                  hintText: 'What did the students want to know?',
                  labelText: 'Question',
                  helperText: 'Required',
                  errorText: _showValidation ? _error : null,
                  controller: _controller,
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
