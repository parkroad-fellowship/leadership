import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFEntryType {
  @JsonValue(1)
  credit,
  @JsonValue(2)
  debit
  ;

  int get apiKey {
    return switch (this) {
      PRFEntryType.credit => 1,
      PRFEntryType.debit => 2,
    };
  }
}
