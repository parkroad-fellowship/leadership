import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFChargeType {
  @JsonValue(1)
  mpesaDefault,
  @JsonValue(2)
  mpesaOtherRegisteredUser,
  @JsonValue(3)
  mpesaAgentWithdrawal,
  @JsonValue(4)
  mpesaATMWithdrawal,
  @JsonValue(5)
  cash
  ;

  String get name {
    switch (this) {
      case PRFChargeType.mpesaDefault:
        return '(MPESA) User/Till/Paybill';
      case PRFChargeType.mpesaOtherRegisteredUser:
        return '(MPESA) Other Registered User';
      case PRFChargeType.mpesaAgentWithdrawal:
        return '(MPESA) Agent Withdrawal';
      case PRFChargeType.mpesaATMWithdrawal:
        return '(MPESA) ATM Withdrawal';
      case PRFChargeType.cash:
        return 'Cash';
    }
  }

  int get apiKey {
    switch (this) {
      case PRFChargeType.mpesaDefault:
        return 1;
      case PRFChargeType.mpesaOtherRegisteredUser:
        return 2;
      case PRFChargeType.mpesaAgentWithdrawal:
        return 3;
      case PRFChargeType.mpesaATMWithdrawal:
        return 4;
      case PRFChargeType.cash:
        return 5;
    }
  }
}
