import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFApprovalStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  approved,
  @JsonValue(3)
  rejected,
}
