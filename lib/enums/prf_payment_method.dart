import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFPaymentMethod {
  @JsonValue(1)
  mpesa,
  @JsonValue(2)
  bankTransfer,
  @JsonValue(3)
  paybill,
  @JsonValue(4)
  tillNumber,
}
