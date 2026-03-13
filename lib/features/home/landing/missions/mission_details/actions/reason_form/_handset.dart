import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/actions/_shared/mission_sheet_section.dart';
import 'package:prf_design/prf_design.dart';

class MissionReasonFormSheet extends StatefulWidget {
  const MissionReasonFormSheet({
    required this.hintText,
    required this.submitLabel,
    super.key,
  });

  final String hintText;
  final String submitLabel;

  @override
  State<MissionReasonFormSheet> createState() => _MissionReasonFormSheetState();
}

class _MissionReasonFormSheetState extends State<MissionReasonFormSheet> {
  late final TextEditingController _controller;

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                title: 'Reason',
                subtitle: 'Optional context for this action',
                child: PRFTextAreaInput(
                  hintText: widget.hintText,
                  labelText: 'Reason',
                  helperText: 'Optional',
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
