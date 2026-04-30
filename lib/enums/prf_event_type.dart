import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFEventType {
  @JsonValue(1)
  member(1),
  @JsonValue(2)
  leadership(2),
  ;

  const PRFEventType(this.apiKey);

  final int apiKey;
}
