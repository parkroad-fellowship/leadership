import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_widgets/input/text/_handset.dart';
import 'package:leadership/shared_widgets/input/text/_tablet.dart';

class PRFTextInput extends StatelessWidget {
  const PRFTextInput({
    required this.hintText,
    required this.controller,
    super.key,
    this.enabled = true,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final String hintText;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => PRFTextInputTablet(
        hintText: hintText,
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        textCapitalization: textCapitalization,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => PRFTextInputHandset(
          hintText: hintText,
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
        ),
        tablet: (_, _) => PRFTextInputTablet(
          hintText: hintText,
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
        ),
      ),
    );
  }
}
