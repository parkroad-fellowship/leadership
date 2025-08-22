import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFMissionStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  approved,
  @JsonValue(3)
  rejected,
  @JsonValue(4)
  cancelled,
  @JsonValue(5)
  serviced,
  @JsonValue(6)
  fullySubscribed,
  @JsonValue(7)
  postponed;

  String get name {
    switch (this) {
      case PRFMissionStatus.pending:
        return 'Pending';
      case PRFMissionStatus.approved:
        return 'Approved';
      case PRFMissionStatus.rejected:
        return 'Rejected';
      case PRFMissionStatus.cancelled:
        return 'Cancelled';
      case PRFMissionStatus.serviced:
        return 'Serviced';
      case PRFMissionStatus.fullySubscribed:
        return 'Fully Subscribed';
      case PRFMissionStatus.postponed:
        return 'Postponed';
    }
  }

  int get apiKey {
    switch (this) {
      case PRFMissionStatus.pending:
        return 1;
      case PRFMissionStatus.approved:
        return 2;
      case PRFMissionStatus.rejected:
        return 3;
      case PRFMissionStatus.cancelled:
        return 4;
      case PRFMissionStatus.serviced:
        return 5;
      case PRFMissionStatus.fullySubscribed:
        return 6;
      case PRFMissionStatus.postponed:
        return 7;
    }
  }
}
