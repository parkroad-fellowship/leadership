import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFEntryType {
  @JsonValue(1)
  credit(1),
  @JsonValue(2)
  debit(2),
  ;

  const PRFEntryType(this.apiKey);

  final int apiKey;
}
