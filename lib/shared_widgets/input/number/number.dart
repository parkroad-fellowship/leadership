import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_widgets/input/number/_handset.dart';
import 'package:leadership/shared_widgets/input/number/_tablet.dart';

class PRFNumberInput extends StatelessWidget {
  const PRFNumberInput({
    required this.hintText,
    required this.controller,
    super.key,
    this.isLoading = false,
    this.prefixText,
  });

  final String hintText;
  final TextEditingController controller;
  final bool isLoading;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => PRFNumberInputTablet(
        hintText: hintText,
        controller: controller,
        isLoading: isLoading,
        prefixText: prefixText,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => PRFNumberInputHandset(
          hintText: hintText,
          controller: controller,
          isLoading: isLoading,
          prefixText: prefixText,
        ),
        tablet: (_, _) => PRFNumberInputTablet(
          hintText: hintText,
          controller: controller,
          isLoading: isLoading,
          prefixText: prefixText,
        ),
      ),
    );
  }
}
