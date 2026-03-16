import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFApprovalStatus {
  @JsonValue(1)
  pending(1, 'Pending', Icons.hourglass_empty),
  @JsonValue(2)
  underReview(2, 'Under Review', Icons.hourglass_empty),
  @JsonValue(3)
  approved(3, 'Approved', Icons.check_circle),
  @JsonValue(4)
  rejected(4, 'Rejected', Icons.cancel),
  @JsonValue(5)
  recalled(5, 'Recalled', Icons.undo),
  @JsonValue(99)
  ghost(99, 'Zero-Based', Icons.help_outline),
  ;

  const PRFApprovalStatus(this.apiKey, this._label, this.icon);

  final int apiKey;
  final String _label;
  final IconData icon;

  String get name => _label;

  Color color(ThemeData theme) {
    return switch (this) {
      pending => theme.colorScheme.secondary,
      underReview => Colors.orange,
      approved => Colors.green,
      rejected => theme.colorScheme.error,
      recalled => Colors.grey,
      ghost => Colors.transparent,
    };
  }
}
