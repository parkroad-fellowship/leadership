import 'package:flutter/material.dart';
import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:prf_design/prf_design.dart';

/// Theme-aware colours and localised labels for [PRFApprovalStatus].
///
/// Use instead of `PRFApprovalStatus.color(theme)` (which returns fixed
/// `Colors.*` values that ignore dark mode). Text drawn on [statusSet].main
/// must use `.onColor`; text on `.background` must use `.foreground`.
extension PRFApprovalStatusStyle on PRFApprovalStatus {
  StatusColorSet statusSet(BuildContext context) {
    final status = context.statusColors;
    return switch (this) {
      PRFApprovalStatus.pending => status.pending,
      PRFApprovalStatus.underReview => status.warning,
      PRFApprovalStatus.approved => status.success,
      PRFApprovalStatus.rejected => status.error,
      PRFApprovalStatus.recalled => status.ignored,
      PRFApprovalStatus.ghost => status.info,
    };
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      PRFApprovalStatus.pending => l10n.requisitionsStatusPending,
      PRFApprovalStatus.underReview => l10n.requisitionsStatusUnderReview,
      PRFApprovalStatus.approved => l10n.requisitionsStatusApproved,
      PRFApprovalStatus.rejected => l10n.requisitionsStatusRejected,
      PRFApprovalStatus.recalled => l10n.requisitionsStatusRecalled,
      PRFApprovalStatus.ghost => l10n.requisitionsStatusZeroBased,
    };
  }
}
