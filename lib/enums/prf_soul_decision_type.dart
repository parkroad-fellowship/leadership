import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFSoulDecisionType {
  @JsonValue(1)
  salvation(1, 'Salvation'),
  @JsonValue(2)
  rededication(2, 'Rededication'),
  @JsonValue(3)
  camp(3, 'Camp'),
  @JsonValue(4)
  prayer(4, 'Prayer'),
  @JsonValue(5)
  other(5, 'Other'),
  ;

  const PRFSoulDecisionType(this.apiKey, this._label);

  final int apiKey;
  final String _label;

  String get name => _label;
}
