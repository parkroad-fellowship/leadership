part of 'create_payment_instruction_cubit.dart';

@freezed
abstract class CreatePaymentInstructionState
    with _$CreatePaymentInstructionState {
  const factory CreatePaymentInstructionState.initial() = _Initial;
  const factory CreatePaymentInstructionState.loading() = _Loading;
  const factory CreatePaymentInstructionState.loaded() = _Loaded;
  const factory CreatePaymentInstructionState.error(String message) = _Error;
}
