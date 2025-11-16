import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFApprovalStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  underReview,
  @JsonValue(3)
  approved,
  @JsonValue(4)
  rejected,
  @JsonValue(5)
  recalled;

  Color color(ThemeData theme) {
    switch (this) {
      case PRFApprovalStatus.pending:
        return theme.colorScheme.secondary;
      case PRFApprovalStatus.underReview:
        return Colors.orange;
      case PRFApprovalStatus.approved:
        return Colors.green;
      case PRFApprovalStatus.rejected:
        return theme.colorScheme.error;
      case PRFApprovalStatus.recalled:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case PRFApprovalStatus.pending:
        return Icons.hourglass_empty;
      case PRFApprovalStatus.underReview:
        return Icons.hourglass_empty;
      case PRFApprovalStatus.approved:
        return Icons.check_circle;
      case PRFApprovalStatus.rejected:
        return Icons.cancel;
      case PRFApprovalStatus.recalled:
        return Icons.undo;
    }
  }

  String get name {
    switch (this) {
      case PRFApprovalStatus.pending:
        return 'Pending';
      case PRFApprovalStatus.underReview:
        return 'Under Review';
      case PRFApprovalStatus.approved:
        return 'Approved';
      case PRFApprovalStatus.rejected:
        return 'Rejected';
      case PRFApprovalStatus.recalled:
        return 'Recalled';
    }
  }

  int get apiKey {
    switch (this) {
      case PRFApprovalStatus.pending:
        return 1;
      case PRFApprovalStatus.underReview:
        return 2;
      case PRFApprovalStatus.approved:
        return 3;
      case PRFApprovalStatus.rejected:
        return 4;
      case PRFApprovalStatus.recalled:
        return 5;
    }
  }
}
