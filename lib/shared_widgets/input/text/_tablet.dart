import 'package:flutter/material.dart';

class PRFTextInputTablet extends StatelessWidget {
  const PRFTextInputTablet({
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
    final theme = Theme.of(context);

    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: textCapitalization,
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            16,
          ),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: .2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: .2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: .1),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }
}
