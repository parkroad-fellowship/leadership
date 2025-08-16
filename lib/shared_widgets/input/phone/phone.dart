import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_widgets/input/phone/_handset.dart';
import 'package:leadership/shared_widgets/input/phone/_tablet.dart';

class PRFPhoneInput extends StatelessWidget {
  const PRFPhoneInput({
    required this.hintText,
    required this.controller,
    super.key,
    this.enabled = true,
    this.onChanged,
    this.maxLength,
  });

  final String hintText;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => PRFPhoneInputTablet(
        hintText: hintText,
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        maxLength: maxLength,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => PRFPhoneInputHandset(
          hintText: hintText,
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          maxLength: maxLength,
        ),
        tablet: (_, _) => PRFPhoneInputTablet(
          hintText: hintText,
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          maxLength: maxLength,
        ),
      ),
    );
  }
}
