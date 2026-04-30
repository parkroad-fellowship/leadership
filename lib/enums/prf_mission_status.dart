import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFMissionStatus {
  @JsonValue(1)
  pending(1, 'Pending'),
  @JsonValue(2)
  approved(2, 'Approved'),
  @JsonValue(3)
  rejected(3, 'Rejected'),
  @JsonValue(4)
  cancelled(4, 'Cancelled'),
  @JsonValue(5)
  serviced(5, 'Serviced'),
  @JsonValue(6)
  fullySubscribed(6, 'Fully Subscribed'),
  @JsonValue(7)
  postponed(7, 'Postponed'),
  ;

  const PRFMissionStatus(this.apiKey, this._label);

  final int apiKey;
  final String _label;

  String get name => _label;
}
