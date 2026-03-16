import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFMissionSubscriptionStatus {
  @JsonValue(1)
  pending(1, 'Pending'),
  @JsonValue(2)
  approved(2, 'Approved'),
  @JsonValue(3)
  withdrawn(3, 'Withdrawn'),
  @JsonValue(4)
  fullySubscribed(4, 'Fully subscribed'),
  @JsonValue(5)
  conflict(5, 'Conflict'),
  ;

  const PRFMissionSubscriptionStatus(this.apiKey, this._label);

  final int apiKey;
  final String _label;

  String get name => _label;
}
