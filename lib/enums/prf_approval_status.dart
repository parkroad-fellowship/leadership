import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prf_design/prf_design.dart';

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
  ghost(99, 'Zero-Based', Icons.help_outline);

  const PRFApprovalStatus(this.apiKey, this._label, this.icon);

  final int apiKey;
  final String _label;
  final IconData icon;

  String get name => _label;

  /// Theme-aware colours and localised labels live in the
  /// `PRFApprovalStatusStyle` extension
  /// (`lib/shared/requisitions/widgets/approval_status_style.dart`):
  /// use `status.statusSet(context)` and `status.label(l10n)`.
  @Deprecated('Use PRFApprovalStatusStyle.statusSet(context)')
  Color color(ThemeData theme) {
    final status = theme.extension<PRFStatusExtension>();
    if (status == null) return theme.colorScheme.primary;
    return switch (this) {
      pending => status.pending.main,
      underReview => status.warning.main,
      approved => status.success.main,
      rejected => status.error.main,
      recalled => status.ignored.main,
      ghost => status.info.main,
    };
  }
}
