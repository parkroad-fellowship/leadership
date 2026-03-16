import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFActiveStatus {
  @JsonValue(1)
  inactive(1),
  @JsonValue(2)
  active(2),
  ;

  const PRFActiveStatus(this.apiKey);

  final int apiKey;
}
