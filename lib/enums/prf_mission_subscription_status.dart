import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFMissionSubscriptionStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  approved,
  @JsonValue(3)
  withdrawn,
  @JsonValue(4)
  fullySubscribed,
  @JsonValue(5)
  conflict
  ;

  String get name {
    switch (this) {
      case PRFMissionSubscriptionStatus.pending:
        return 'Pending';
      case PRFMissionSubscriptionStatus.approved:
        return 'Approved';
      case PRFMissionSubscriptionStatus.withdrawn:
        return 'Withdrawn';
      case PRFMissionSubscriptionStatus.fullySubscribed:
        return 'Fully subscribed';
      case PRFMissionSubscriptionStatus.conflict:
        return 'Conflict';
    }
  }

  int get apiKey {
    switch (this) {
      case PRFMissionSubscriptionStatus.pending:
        return 1;
      case PRFMissionSubscriptionStatus.approved:
        return 2;
      case PRFMissionSubscriptionStatus.withdrawn:
        return 3;
      case PRFMissionSubscriptionStatus.fullySubscribed:
        return 4;
      case PRFMissionSubscriptionStatus.conflict:
        return 5;
    }
  }
}
